require! bcrypt

module.exports = ({Schema}) ->

    schema = new Schema {
        name: String
        email: String
        password: String # hashed with bcrypt
        mine-credentials: [{root: String, token: String}] # preferred mine is [0]
    }

    schema.pre \save, (user, next) -> bcrypt.hash user.password, 10, (err, hash) ->
        | err?      => next err
        | otherwise => user.password = hash; next!

    schema.methods.load = (name, password) ->
        def = Q.defer!
        found = (user) -> bcrypt.compare password, user.password, (err, ok) ->
            | err?      => def.reject err
            | not ok    => def.reject new Error("password does not match")
            | otherwise => def.resolve user

        @db.model(module.exports.model-name).find({name}).exec!then found, def~reject
        def.promise

    return schema

module.exports.model-name = \User
