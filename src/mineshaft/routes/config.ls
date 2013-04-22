require! {
    debug,
    JSONStream,
    handle: './error'
}

log = debug \mineshaft/routes/config

excluded-fields = '-_id -labels._id -user'

exports.get = ({db: {Tool}, conf}, req, res) -->
    res.type \json
    user = req.user
    output = JSONStream.stringify!
        ..pipe res

    merge-with-default-tools = (custom-tools) ->
        log "Found %d tools for %s", custom-tools.length, user

        stream = Tool.find({user: conf.db.admin-user}).select(excluded-fields).lean!stream!

        if custom-tools.length
            custom-map = fold ((m, t) -> m[t.slug] = t), {}, custom-tools

            serve = (tool) ->
                if custom = custom-map[tool.slug]
                    tool <<< custom
                output.write tool

            stream
                ..on \error, handle!
                ..on \data, serve
                ..on \end, output~end
        else
            stream.pipe(output).on \error, handle!

    if user?
        log "Looking for tools belonging to %s", user
        Tool.find({user}).exec!then merge-with-default-tools, handle!
    else
        merge-with-default-tools []

