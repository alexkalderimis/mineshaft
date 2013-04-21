require! mongoose-types: 'mongoose-types'

module.exports = (mongoose) ->

    mongoose-types.load-types mongoose

    new mongoose.Schema {
        uri: mongoose.SchemaTypes.Url
        method: String
        state: String
        body: String
        headers: {}
    }

module.exports.model-name = \Request
