require! {debug, object-id: mongojs.ObjectId, handle: './error'}

log = debug \mineshaft/routes/request

exports.get = (conf, db, req, res) -->
    query = _id: object-id req.params.id
    log 'query = %j', query
    searching = db.requests.find(query).limit(1)
    searching.on \data, res~send
    searching.on \error, handle!
    searching.on \end, res~end


