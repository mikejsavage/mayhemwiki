local db = require( "db" )

return function( request, title )
	for revision in db( [[
		SELECT r.date, r.id, u.username
		FROM revisions AS r, users AS u
		WHERE r.title = ? AND r.author = u.id ORDER BY date DESC
	]], title ) do
		request:html( function( html )
			return html.div( {
				html.a( { href = "/" .. title .. "/" .. revision.id }, revision.date ),
				" by " .. revision.username,
			} )
		end )
	end
end
