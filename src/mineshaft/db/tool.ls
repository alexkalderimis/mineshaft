module.exports = ({Schema}) ->

    schema = new Schema {
        user: String
        slug: String
        help: String
        labels: [
            label: String
            weight: Number
            place: String
            keywords: Array
        ]
    }

    return schema

module.exports.model-name = \Tool

