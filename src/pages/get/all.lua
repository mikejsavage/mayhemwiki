local db = require( "db" )

return function( request )
	request:write( "<h1>All pages</h1>" )

	for page in db( [[
		SELECT p.title, r.date, u.username
		FROM pages AS p, revisions AS r, users AS u
		WHERE p.revision_id == r.id AND r.author == u.id
		ORDER BY p.title COLLATE NOCASE ASC
	]] ) do
		request:html( function( html )
			return html.div( {
				html.a( { href = "/" .. page.title }, page.title ),
				" - last updated at " .. page.date .. " by " .. page.username,
			} )
		end )
	end
end
