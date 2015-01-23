local db = require( "db" )
local log = require( "log" )
local csrf = require( "flea.csrf" )

return function( request )
	if not request.post.user_id then
		return request:bad_request()
	end

	if not csrf.validate( request ) then
		return
	end

	local user = db:first( "SELECT username FROM users WHERE id = ?", request.post.user_id )

	if user then
		db:run( "UPDATE users SET enabled = 1 WHERE id = ?", request.post.user_id )
		log.info( "%s enabled account %s", request.user.username, user.username )
	end

	request:redirect( "/accounts?enabled" )
end
