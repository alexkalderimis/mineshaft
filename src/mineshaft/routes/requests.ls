require! {
    debug,
    JSONStream,
    handle: './error',
    Request: './../model/request'
}

log = debug \mineshaft/routes/requests

exports.get = ({db}, req, res) --> 
    res.type \json
    searching = db.requests.find!
        ..on \error, handle!
        ..pipe(JSONStream.stringify!).pipe res
        ..on \end, res~end

exports.post = ({events, db}, req, res) -->
    doc = Request req.body
    log 'Doc: %j', doc
    db.requests.save doc, handle ({_id}:saved) ->
        events.emit \requests:saved, saved
        location = '/requests/' + _id
        res
            ..status-code = 201
            ..set-header \Location, location
            ..send {location}


