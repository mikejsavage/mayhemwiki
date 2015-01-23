local db = require( "db" )
local csrf = require( "flea.csrf" )

return function( request )
	if not request.post.user_id then
		return request:bad_request()
	end

	if not csrf.validate( request ) then
		return
	end

	db:run( "UPDATE users SET enabled = 1 WHERE id = ?", request.post.user_id )

	request:redirect( "/accounts?enabled" )
end
