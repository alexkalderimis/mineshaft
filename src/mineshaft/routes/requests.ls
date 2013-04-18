require! {
    debug,
    JSONStream,
    handle: './error',
    Request: './../model/request'
}

log = debug \mineshaft/routes/requests

exports.get = (conf, db, req, res) --> 
    res.type \json
    searching = db.requests.find!
        ..on \error, handle!
        ..pipe(JSONStream.stringify!).pipe res
        ..on \end, res~end

exports.post = (conf, db, req, res) -->
    doc = Request req.body
    log 'Doc: %j', doc
    db.requests.save doc, handle ->
        db.requests.find doc, handle (docs) ->
          location = '/requests/' + docs[0]._id
          res
            ..status-code = 201
            ..set-header \Location, location
            ..send accepted: true, location: location

