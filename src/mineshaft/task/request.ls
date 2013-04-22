require! {
    debug,
    request,
    object-id: mongojs.ObjectId,
    Daemon: './daemon'
}

log = debug \mineshaft/task/request

best-error = (err, resp, body) ->
    | body?.error => body.error
    | err?        => "#{err.to-string!}: #{ err.stack }"
    | otherwise   => resp.status-code

succeeded = (err, resp, body) -> not err? and resp?.status-code < 400

module.exports = class RequestDaemon extends Daemon

    ({@events, @db}) ->

    run: ->
        @db.Request.on \created, @~dispatch
        @db.Request.find(state: \PENDING).stream!
            .on \error, log
            .on \data, @~dispatch

    handle: (req) ->
        @backoff = @min-backoff
        {Response} = @db
        events = @events

        req.state = \RUNNING
        req.save!

        options = req.to-request-opts!
        accepts = options.headers.Accepts ?= 'application/json'
        options.json = true if accepts == /json/

        log 'request(%j)', options

        request options, (err, resp, body) ->
            response = new Response {
                request: req._id
                status-code: resp.status-code
                created: new Date()
            }
            [state, props] =
                | succeeded ... => [ \COMPLETE, {body} ]
                | otherwise     => [ \FAILED,   {err: best-error ...}]

            response <<< props

            response.save (err) ->
                log "Error saving response: %s", err if err?
                req.state = if err? then \PENDING else state
                req.save!

