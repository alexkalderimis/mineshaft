require! {Q: q, mongo: mongojs, config: './config'}

connect = -> config!.get(\db).then -> mongo it.dsn, it.collections

module.exports = connect
