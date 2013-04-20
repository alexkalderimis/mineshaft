require! {
    Q: q,
    mongo: mongoose,
    config: './config',
    request: './db/request',
    response: './db/response'
}

connect = -> config!.get(\db)
    .then ->
        mongo.connect it.dsn
        deferred = Q.defer!
        db = mongo.connection
        db.on \error, -> deferred.reject new Error('Connection error: ' + it)
        db.on \open, -> deferred.resolve mongo
        return deferred.promise
    .then ->
        [Request, Response] = [request, response].map -> mongo.model it.name, it mongo
        {Request, Response, mongo}

module.exports = connect
