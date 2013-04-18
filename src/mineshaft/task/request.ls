require! {debug, request, object-id: mongojs.ObjectId}

log = debug \mineshaft/task/request

module.exports = class RequestDaemon

    (@db) ->

    paused: false
    backoff: 1000ms
    max-backoff: 60sec * 1000ms
    min-backoff: 1000ms

    pause: -> @paused = true

    run: ->
        @paused = false
        searching = @db.requests.find( state: \PENDING )
            ..on \error, @~pause
            ..on \data, @~handle
            ..on \end, @~recur

    recur: ->
        return if @paused
        back-off = @backoff
        log 'Recurring in %d ms', back-off
        @backoff = Math.min @max-backoff, back-off * 2
        setTimeout @~run, back-off

    handle: (options) ->
        @backoff = @min-backoff
        {responses, requests} = @db
        options.headers.Accepts ?= 'application/json'
        log 'options: %j', options
        req = _id: options._id

        requests.update req, {$set: {state: \RUNNING}}

        request options, (err, resp, body) ->
            if err?
                responses.save {err: err.to-string!, request: options._id}
                requests.update req, {$set: {state: \FAILED}}
            else
                responses.save {body, request: options._id}, (err) ->
                    to-set =
                        | err?      => state: \PENDING
                        | otherwise => state: \COMPLETE
                    log err if err?
                    requests.update req, {$set: to-set}

