local db = require( "db" )

return function( request )
	request:write( "<h1>Recent changes</h1>" )

	for revision in db( [[
		SELECT r.id, r.title, r.date, u.username
		FROM revisions AS r, users AS u
		WHERE r.author == u.id
		ORDER BY r.date DESC
		LIMIT 250
	]] ) do
		request:html( function( html )
			return html.div( {
				html.a( { href = "/" .. revision.title }, revision.title ),
				" was modified by " .. revision.username .. " at " .. revision.date,
			} )
		end )
	end
end
