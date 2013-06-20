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

module.exports = build-app

debug = log-factory \mineshaft

launch! unless module.parent

function launch then build-app!.then (app) ->
    app.listen app.port
    debug 'Listening on port %s', app.port

function build-app then Q.all([configure!, connect!]).then _build-app

function _build-app [conf, db]
    debug """\n
    _________________________________________________   __
    |  \\/  (_)               | |          / _| |     |.|
    | .  . |_ _ __   ___  ___| |__   __ _| |_| |_    |.|
    | |\\/| | | '_ \\ / _ \\/ __| '_ \\ / _` |  _| __|   |.|
    | |  | | | | | |  __/\\__ \\ | | | (_| | | | |_    |x|
    \\_|  |_/_|_| |_|\\___||___/_| |_|\\__,_|_|  \\__|   |.|
    _________________________________________________|.|  
    Digging a #{ conf.environment } mineshaft...
    """

    app = express!
        ..events = new EventEmitter()
        ..conf = conf
        ..db = db
        ..clear-db = -> [coll.remove!exec! for coll of db]
        ..use express.logger conf.logger
        ..use express.compress!
        ..use express.bodyParser!
        ..use express.cookieParser conf.cookie.secret
        ..use express.cookieSession {secret: conf.cookie.secret}
        ..use express.static __dirname + '/../static'
        ..use '/socket.io', express.static __dirname + '/../node_modules/socket.io/lib'
        ..http!io!

    for [verb, path, handler] in routes
        app[verb] path, handler app

    for [event, handlers] in sockets
        app.io.route event, handlers app

    app.clear-db! if conf.db.clear

    # Start an interleaved set of requests, checking the request queue.
    daemon = new RequestDaemon app
        ..run!

    app.port = conf.webapp.port

    return app

