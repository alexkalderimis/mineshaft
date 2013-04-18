require! {
    express,
    Q: q, 
    log-factory: debug,
    configure: './mineshaft/config',
    connect: './mineshaft/db',
    routes: './mineshaft/routes',
    RequestDaemon: './mineshaft/task/request'
}

debug = log-factory \mineshaft

Q.all([configure!, connect!])
    .then build-app
    .done!

function build-app [conf, db]
    app = express!
        ..use express.logger conf.logger
        ..use express.bodyParser!

    for [verb, path, handler] in routes
        app[verb] path, handler conf, db

    # Start an interleaved set of requests, checking the request queue.
    daemon = new RequestDaemon db
        ..run!

    port = conf.webapp.port

    app.listen port
    debug 'Listening on port %s', port

