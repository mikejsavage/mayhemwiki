local bcrypt = require( "bcrypt" )

local db = require( "db" )
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

	db:run( "UPDATE users SET password = ?, change_password = 1 WHERE id = ?", digest, request.post.user_id )

	request:redirect( "/accounts?reset=" .. password )
end
