module.exports = (g) ->
    
  Q = require 'q'

  g.loadNpmTasks('grunt-contrib-watch')
  g.loadNpmTasks('grunt-simple-mocha')
  g.loadNpmTasks('grunt-contrib-clean')

  log = g.log.writeln

  g.registerTask 'default', ['clean', 'build', 'close', 'run']

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
    process.exit();

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


