require! debug

log = debug \mineshaft/sockets

responses = ({db: {Response}}, req) -->
    since =
        | req.data? => new Date(req.data)
        | otherwise => new Date()
    req.io.respond \START
    log 'Searching for responses since %s', since
    deliver = -> req.io.emit \responses:get, it
    stream = Response.find( {created: {$gt: since }} ).stream!
        ..on \error, -> req.io.emit \error, {error: "#{ it }"}
        ..on \data, deliver
        ..on \end, -> Response.on \created, deliver

module.exports = [
    ['responses', responses]
]
