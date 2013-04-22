require! {
    debug,
    JSONStream,
    handle: './error',
    to-request: './../model/request'
}

log = debug \mineshaft/routes/requests

exports.get = ({db: {Request}}, req, res) -->
    res.type \json
    searching = Request.find().stream!
        ..on \error, handle!
        ..pipe(JSONStream.stringify!).pipe res
        ..on \end, res~end

exports.post = ({db: {Request}}, req, res) -->
    doc = new Request to-request req.body
    log 'Doc: %j', doc
    doc.save handle ({_id}:saved) ->
        location = '/requests/' + _id
        res
            ..status-code = 201
            ..set-header \Location, location
            ..send {location}


