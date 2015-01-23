local bcrypt = require( "bcrypt" )
local db = require( "db" )
local time = require( "flea.time" )

return function( request )
	if not request.post.username or not request.post.password then
		return request:bad_request()
	end

	local user = db:first( "SELECT id, password FROM users WHERE username = ?", request.post.username:lower() )

	-- there is a timing attack here that can reveal if a username
	-- is valid or not, but given our threat model i don't care
	if user then
		if bcrypt.verify( request.post.password, user.password ) then
			local options = { httponly = true, path = "/" }
			request:set_cookie( "session", user.id, time.days( 30 ), options )

			return request:redirect( request.post.redirect or "/" )
		end
	end

	local location = request.post.redirect or "/"
	request:redirect( location .. "?badlogin" )
end
