local bcrypt = require( "bcrypt" )

local db = require( "db" )
local words = require( "words" )
local csrf = require( "flea.csrf" )

return function( request )
	if not request.post.username then
		return request:bad_request()
	end

	if not csrf.validate( request ) then
		return
	end

	local user = db:first( "SELECT 1 FROM users WHERE username = ?", request.post.username )

	if user then
		return request:redirect( "/accounts?exists" )
	end

	local password = words.get_random()
	local digest = bcrypt.digest( password, config.bcrypt_rounds )

	db:run( "INSERT INTO users ( username, password ) VALUES ( ?, ? )", request.post.username, digest )

	request:redirect( "/accounts?newuser=" .. password )
end
