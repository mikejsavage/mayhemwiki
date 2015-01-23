local bcrypt = require( "bcrypt" )

local db = require( "db" )
local log = require( "log" )
local words = require( "words" )
local csrf = require( "flea.csrf" )

return function( request )
	if not request.post.username then
		return request:bad_request()
	end

	if not csrf.validate( request ) then
		return
	end

	if request.post.username == "" then
		return request:redirect( "/accounts" )
	end

	request.post.username = request.post.username:lower()

	local user = db:first( "SELECT 1 FROM users WHERE username = ?", request.post.username )

	if user then
		return request:redirect( "/accounts?exists" )
	end

	local password = words.get_random()
	local digest = bcrypt.digest( password, config.bcrypt_rounds )

	db:run( "INSERT INTO users ( username, password ) VALUES ( ?, ? )", request.post.username, digest )
	log.info( "%s added account %s", request.user.username, request.post.username )

	request:redirect( "/accounts?newuser=" .. password )
end
