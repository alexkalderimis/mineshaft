
module.exports = (mongoose) ->
    {ObjectId, Mixed} = mongoose.Schema.Types
    new mongoose.Schema {
        error: String
        request: ObjectId
        body: Mixed
        status-code: Number
        created: Date
    }

module.exports.model-name = \Response

