
module.exports = (mongoose) ->
    {ObjectId, Mixed} = mongoose.Schema.Types
    schema = new mongoose.Schema {
        error: String
        request: ObjectId
        body: Mixed
        status-code: Number
        created: Date
    }

    schema.post \save, (doc) -> @db.model(\Response).emit \created, doc

    return schema

module.exports.model-name = \Response

