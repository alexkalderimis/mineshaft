module.exports = (g) ->
    
  Q = require 'q'
  request = require 'request'

  g.loadNpmTasks('grunt-contrib-watch')
  g.loadNpmTasks('grunt-simple-mocha')
  g.loadNpmTasks('grunt-contrib-clean')

  log = g.log.writeln

  log "Running under #{ g.version }"

  g.registerTask 'default', ['clean', 'build', 'close', 'run']

  g.registerTask 'steps', 'Checkout a version of steps', ->
    g.config.requires('steps.uri', 'steps.dest')

    uri = g.config.get 'steps.uri'
    dest = g.config.get 'steps.dest'

    done = @async()

    if g.file.exists dest
      log "Deleting old #{ dest }"
      g.file.delete dest
    
    log "Making #{ dest }"
    g.file.mkdir dest

    log "Cloning #{ uri } --> #{ dest }"
    g.util.spawn {cmd: 'git', args: ['clone', uri, dest]}, done

  g.registerTask 'load-tools', 'Get the latest tool definitions', (environment) ->
    @requiresConfig 'tools.src', 'tools.model', 'tools.method', 'tools.primaryKey'
    @requires 'build', 'steps'
    throw new Error("environment argument is required") unless environment

    {src, model, method, primaryKey} = g.config('tools')
    opts = {upsert: true}

    tools = require src

    log "Found #{ tools.length } tools"

    done = this.async()

    toQuery = (conf) -> (x) ->
      q = {}
      q[primaryKey] = x[primaryKey]
      q.$or = [{user: {$exists: false}}, {user: conf.db.adminUser}]
      return q

    addUser = (conf) -> (x) ->
      x.user = conf.db.adminUser
      x

    n = 0
    connect = require('./build/mineshaft/db')
    configure = require('./build/mineshaft/config')
    Q.all([connect(environment), configure(environment)])
      .then( ([db, conf]) -> [db[model], toQuery(conf), addUser(conf)])
      .then( ([C, toQ, addU]) ->  ( C[method](toQ(t), addU(t), opts).exec() for t in tools ) )
      .then( (promises) -> log "Loading tools"; Q.all(promises) )
      .then((-> done()), done)

  g.registerMultiTask 'build', 'compile livescripts', ->
    done = @async()
    {files, dir, dest, flags} = @data

    dest ?= dir

    args =
      cmd: './node_modules/.bin/livescript',
      args: [ '--compile', '--output', dest]

    if (flags)
      args.args = flags.map( (f) -> "--#{ f }" ).concat args.args

    g.log.verbose.writeln args.cmd, args.args.join ' '

    if dir
      log "Compiling #{ dir } --> #{ dest }"
      args.args.push dir
    else if files
      log "Compiling #{ files.length } files to #{ dest }"
      args.args = ['join'].concat(args.args).concat files

    g.util.spawn(args, done)

  close = null
  g.registerTask 'close', 'Close the server, if it is running', ->
    if close?
      close()
    else
      log "Server not running"

  launchServer = (environment, done) ->
    log "Launching #{ environment } server"
    if environment?
      process.env.ENVIRONMENT = environment
    process.env.DEBUG ?= 'mineshaft*'
    mineshaft = require './build/mineshaft'
    mineshaft().fail(done).then (app) ->
      server = app.listen app.port
      log "Listening on #{ app.port }"
      close = ->
        log "Closing #{ environment } server"
        server.close()
        done?()

  g.registerTask 'clear-db', 'Clear the db', (environment) ->
    g.task.requires 'build'
    done = this.async()
    return done(new Error("environment argument is required")) unless environment
    connect = require('./build/mineshaft/db')
    connect(environment)
      .then( (db) -> Q.all(Q.ninvoke coll, 'remove', {} for _, coll of db) )
      .fail(done)
      .then(-> done)

  g.registerTask 'run', 'Run the server', (environment) ->
    launchServer environment, this.async()

  g.registerTask 'run-and-watch', 'Run the development server, and restart on changes', (env) ->
    launchServer env
    g.task.run 'watch'

  process.on 'SIGINT', ->
    log "\nCaught ^C - cleaning up"
    close?()
    process.exit()

  g.initConfig
    clean: ['build', 'dist']
    watch:
      files: "src/**/*.ls"
      tasks: "default"
    build:
      compile:
        flags: ["const", "prelude"]
        dir: "src/"
        dest: "build/"
    simplemocha:
      options:
        timeout: 3000
        ignoreLeaks: false
        ui: 'bdd'
        reporter: 'spec'
      all:
        src: 'build/test/mineshaft/*.js'
    steps:
      uri: 'git://github.com/intermine/intermine-steps.git'
      dest: 'steps'
    tools:
      src: './steps/app/tools/Registry'
      model: 'Tool'
      method: 'findOneAndUpdate'
      primaryKey: 'slug'


