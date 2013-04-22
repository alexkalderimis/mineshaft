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
        @events.on \requests:saved, @~dispatch

    handle: (req) ->
        @backoff = @min-backoff
        {Response, Request} = @db
        events = @events

        req.state = \RUNNING
        req.save!

        options = req.to-request-opts!
        accepts = options.headers.Accepts ?= 'application/json'
        options.json = true if accepts == /json/

        log 'options: %j', options

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

            response.save (err, saved) ->
                log "Error saving response: %s", err if err?
                events.emit \saved:response, saved if saved?
                req.state = if err? then \PENDING else state
                log "New state is %s", state
                req.save!

