require! {
    debug,
    JSONStream,
    handle: './error',
    object-id: mongojs.ObjectId
}

log = debug \mineshaft/routes/responses

exports.get = ({db}, req, res) -->
    res.type = \json
    searching = db.responses.find!
        ..on \error, handle!
        ..pipe(JSONStream.stringify!).pipe res
        ..on \end, res~end

exports.by-id = ({db}, req, res) -->
    request = object-id req.params.id
    searching = db.responses.find {request}
        ..on \error, handle!
        ..on \data, res~send
        ..on \end, res~end

