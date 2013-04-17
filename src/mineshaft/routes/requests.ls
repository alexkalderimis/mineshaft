require! {debug, JSONStream, handle: './error'}

log = debug \mineshaft/routes/requests

exports.get = (conf, db, req, res) --> 
    res.type \json
    searching = db.requests.find!
        ..on \error, handle!
        ..pipe(JSONStream.stringify!).pipe res
        ..on \end, res~end

exports.post = (conf, db, req, res) -->
    doc = req.body
    log doc
    db.requests.save doc, handle ->
        db.requests.find doc, handle (docs) ->
          res
            ..status-code =  201
            ..set-header \Location, '/requests/' + docs[0]._id
            ..send {accepted: true}

