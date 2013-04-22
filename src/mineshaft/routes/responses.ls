require! {
    debug,
    JSONStream,
    handle: './error',
    to-oid: mongoose.Types.ObjectId.fromString
}

log = debug \mineshaft/routes/responses

exports.get = ({db: {Response}}, req, res) -->
    res.type = \json
    stream = Response.find!stream!
        ..on \error, handle!
        ..pipe(JSONStream.stringify!).pipe res
        ..on \end, res~end

exports.by-id = ({db: {Response}}, req, res) -->
    query = request: to-oid req.params.id
    stream = Response.find(query).stream!
        ..on \error, handle!
        ..on \data, res~send
        ..on \end, res~end

