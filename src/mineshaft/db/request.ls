require! mongoose-types: 'mongoose-types'

module.exports = (mongoose) ->

    mongoose-types.load-types mongoose

    schema = mongoose.Schema {
        uri: String #mongoose.SchemaTypes.Url
        method: String
        state: String
        body: String
        headers: {}
    }

    schema.methods.to-request-opts = -> {@uri, @body, @headers, @method}

    schema.methods.update-state = (state, cb) -> @update {$set: {state}}, cb

    schema.post \save, (doc) -> @db.model(\Request).emit \created, this if doc.state is \PENDING

    return schema

module.exports.model-name = \Request
