require! {
    index: './routes/index',
    requests: './routes/requests',
    request: './routes/request',
    responses: './routes/responses',
    config: './routes/config'
}

module.exports = routes!

function routes then [
    [\get, '/', index],
    [\get, '/requests', requests.get],
    [\post, '/requests', requests.post],
    [\get, '/requests/:id', request.get],
    [\get, '/responses', responses.get],
    [\get, '/requests/:id/response', responses.by-id],
    [\get, '/tools/Registry', config.get]
]

