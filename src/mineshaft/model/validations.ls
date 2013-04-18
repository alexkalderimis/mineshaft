exports.is-array = (a, msg = "not an array") ->
    throw new Error(msg) unless Array.isArray a
