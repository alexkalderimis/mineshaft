require! {debug, handle: './error'}

log = debug \mineshaft/routes/request

exports.get = ({db: {Request}}, req, res) -->
    query = Request.find-by-id req.params.id
    searching = query.exec!
        ..on-reject handle!
        ..then res~send

