local bcrypt = require( "bcrypt" )

local db = require( "db" )
local csrf = require( "flea.csrf" )
local time = require( "flea.time" )

local function password_sucks( request, password )
	password = password:lower()

	return password == ""
		or password == request.user.username:lower()
		or password == request.user.username:lower():reverse()
		or password:len() < 6
end

return function( request )
	if not request.post.password then
		return request:bad_request()
	end

	if not csrf.validate( request ) then
		return
	end

	local location = request.post.redirect or "/accounts/password"

	if password_sucks( request, request.post.password ) then
		return request:redirect( location .. "?badpassword" )
	end

	local digest = bcrypt.digest( request.post.password, config.bcrypt_rounds )

	db:run( "UPDATE users SET password = ?, change_password = 0 WHERE id = ?", digest, request.user.id )

	request:redirect( location )
end
