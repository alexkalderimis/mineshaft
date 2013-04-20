
module.exports = (mongoose) ->
    {ObjectId, Mixed} = mongoose.Schema.Types
    schema = new mongoose.Schema error: String, request: ObjectId, body: Mixed
        ..name = \Response

