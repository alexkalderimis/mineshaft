require! {
    index: './routes/index',
    requests: './routes/requests',
    request: './routes/request'
}

module.exports = routes!

function routes then [
    [\get, '/', index],
    [\get, '/requests', requests.get],
    [\post, '/requests', requests.post],
    [\get, '/requests/:id', request.get]
]

