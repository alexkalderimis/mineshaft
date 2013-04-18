require! {
    debug,
    request,
    object-id: mongojs.ObjectId,
    Daemon: './daemon'
}

log = debug \mineshaft/task/request

module.exports = class RequestDaemon extends Daemon

    ({@events, @db}) ->

    search: -> @db.requests.find( state: \PENDING )

    handle: (options) ->
        @backoff = @min-backoff
        {responses, requests} = @db
        events = @events
        options.headers.Accepts ?= 'application/json'
        if options.headers.Accepts == /json/
            options.json = true
        log 'options: %j', options
        req = _id: options._id

        requests.update req, {$set: {state: \RUNNING}}

        request options, (err, resp, body) ->
            doc = request: options._id, created: new Date()
            if err? or resp.status-code >= 400
                msg =
                    | err? => err.to-string!
                    | otherwise => resp.status-code
                responses.save doc <<< err: msg
                requests.update req, {$set: {state: \FAILED}}
            else
                responses.save doc <<< {body}, (err, saved) ->
                    events.emit \saved:response, saved
                    to-set =
                        | err?      => state: \PENDING
                        | otherwise => state: \COMPLETE
                    log err if err?
                    requests.update req, {$set: to-set}

