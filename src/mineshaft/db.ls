require! {
    debug,
    Q: q,
    mongo: mongoose,
    config: './config',
    request: './db/request',
    response: './db/response',
    tool: './db/tool',
    user: './db/user'
}

log = debug \mineshaft/db

schema-facs = [request, response, tool, user]

build-models = ->
    log "Building models: #{ map (.model-name), schema-facs }"
    schema-facs |> map -> [it.model-name, mongo.model it.model-name, it mongo]
                |> listToObj

do-connect = ->
    log "Connecting to #{ it.dsn }"
    mongo.connect it.dsn
    deferred = Q.defer!
    db = mongo.connection
    db.on \error, deferred~reject
    db.on \open, deferred~resolve
    return deferred.promise

connect = -> config(it).get(\db).then(do-connect).then(build-models)

module.exports = connect
