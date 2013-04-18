require! debug

log = debug \mineshaft/sockets

responses = ({events, db}, req) -->
    since =
        | req.data? => new Date(req.data)
        | otherwise => new Date()
    req.io.respond \START
    log 'Searching for responses since %s', since
    deliver = -> req.io.emit \responses:get, it
    search = db.responses.find( {created: {$gt: since }} )
        ..on \error, -> req.io.emit \error, {error: "#{ it }"}
        ..on \data, deliver
        ..on \end, -> events.on \saved:response, deliver


module.exports = [
    ['responses', responses]
]
