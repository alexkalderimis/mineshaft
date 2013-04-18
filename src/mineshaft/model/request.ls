require! validator.check

stringify-pair = ([name, value]) -> "#{ name }=#{ encodeURIComponent value }"

URL_ENC = 'application/x-www-form-urlencoded; charset=utf-8'

module.exports = class Request

    ({@uri, @method = \GET, @headers = {}, @json, @auth, params = []}) ~>
        @validate!
        @state = \PENDING
        unless @json?
            @body = params |> map stringify-pair |> (.join \&)
            @headers['Content-Type'] = URL_ENC

    validate: ->
        check(@uri).isUrl!
        check(@method).isIn <[ GET POST PUT DELETE ]>

