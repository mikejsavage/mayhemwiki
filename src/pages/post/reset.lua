local bcrypt = require( "bcrypt" )

local db = require( "db" )
local log = require( "log" )
local words = require( "words" )
local csrf = require( "flea.csrf" )

return function( request )
	if not request.post.user_id then
		return request:bad_request()
	end

	if not csrf.validate( request ) then
		return
	end

	local password = words.get_random()
	local digest = bcrypt.digest( password, config.bcrypt_rounds )

	local user = db:first( "SELECT username FROM users WHERE id = ?", request.post.user_id )

	if user then
		db:run( "UPDATE users SET password = ?, change_password = 1 WHERE id = ?", digest, request.post.user_id )
		log.info( "%s reset %s's password", request.user.username, user.username )
	end


	request:redirect( "/accounts?reset=" .. password )
end
