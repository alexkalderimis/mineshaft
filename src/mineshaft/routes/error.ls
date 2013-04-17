module.exports = (fn = id) -> (err, ...args) ->
    if err?
        res
            ..writeHead 500
            ..send error: "#{ err }", stack: "#{ err.stack }"
    else
        fn ...args

