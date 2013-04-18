require! {
    events.EventEmitter,
    express: 'express.io',
    Q: q, 
    log-factory: debug,
    configure: './mineshaft/config',
    connect: './mineshaft/db',
    routes: './mineshaft/routes',
    sockets: './mineshaft/sockets',
    RequestDaemon: './mineshaft/task/request'
}

debug = log-factory \mineshaft

Q.all([configure!, connect!])
    .then build-app
    .done!

function build-app [conf, db]
    app = express!
        ..events = new EventEmitter()
        ..conf = conf
        ..db = db
        ..use express.logger conf.logger
        ..use express.bodyParser!
        ..use express.static __dirname + '/../static'
        ..use '/socket.io', express.static __dirname + '/../node_modules/socket.io/lib'
        ..http!io!

    for [verb, path, handler] in routes
        app[verb] path, handler app

    for [event, handlers] in sockets
        app.io.route event, handlers app

    if conf.db.clear
        for coll in conf.db.collections
            debug "Clearing #{ coll }"
            db[coll].remove!

    # Start an interleaved set of requests, checking the request queue.
    daemon = new RequestDaemon app
        ..run!

    port = conf.webapp.port

    app.listen port
    debug 'Listening on port %s', port

