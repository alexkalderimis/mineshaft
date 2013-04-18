require! {debug}

log = debug \mineshaft/task/daemon

module.exports = class Daemon

    paused: false
    backoff: 200ms
    max-backoff: 10sec * 1000ms
    min-backoff: 200ms

    pause: -> @paused = true

    run: ->
        @paused = false
        searching = @search!
            ..on \error, @~pause
            ..on \data, @~dispatch
            ..on \end, @~recur
    
    dispatch: (obj) -> process.next-tick ~> @handle obj

    recur: ->
        return if @paused
        back-off = @backoff
        log 'Recurring in %d ms', back-off
        @backoff = Math.min @max-backoff, back-off * 2
        setTimeout @~run, back-off

