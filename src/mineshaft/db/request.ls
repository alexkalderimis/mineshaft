require! mongoose-types

module.exports = (mongoose) ->

    mongoose-types.load-types mongoose

    schema = new mongoose.Schema
        uri: mongoose.SchemaTypes.Url
        method: String
        state: String
        body: String
        headers: {}
    schema.name = \Request
    return schema
