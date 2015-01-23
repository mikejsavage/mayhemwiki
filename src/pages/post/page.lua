local db = require( "db" )
local csrf = require( "flea.csrf" )

return function( request, title )
	if not request.post.contents then
		return request:bad_request()
	end

	if not csrf.validate( request ) then
		return
	end

	db:run( "BEGIN" )
	db:run( "INSERT INTO revisions ( author, title, contents ) VALUES ( ?, ?, ? )",
		request.user.id,
		title,
		request.post.contents
	)
	db:run( "INSERT INTO pages ( title, revision_id ) VALUES ( ?, last_insert_rowid() )", title )
	db:run( "COMMIT" )

	request:redirect( "/" .. title )
end
