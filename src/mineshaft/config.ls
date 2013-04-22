require! {fs, Q: q}

read-file = Q.nfbind fs.readFile

module.exports = load-config

root-dir = __dirname + '/../..'

all-keys = (unique << concatMap keys)
merge-one = (into, a, b) ->
    | not b and not a => into
    | a and not b => into <<< a
    | b and not a => into <<< b
    | otherwise   => into <<< a <<< b
merge = ([into, a, b]) ->
    [ [ n, merge-one (into[n] or {}), a[n], b[n] ] for n in all-keys [into, a, b] ] |> listToObj

read-json = -> read-file it, \utf8 |> (.then JSON.parse)

function load-config env = ( process.env.ENVIRONMENT or \development )
    reading-main-conf = read-json root-dir + '/config.json'
    reading-specific-conf = read-json "#{ root-dir }/config/#{ env }.json"
    defaults =
        webapp:
            port: process.env.PORT
        environment: env

    Q.all [defaults, reading-main-conf, reading-specific-conf]
     .then merge

