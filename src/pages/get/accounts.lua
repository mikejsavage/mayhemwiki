local db = require( "db" )
local csrf = require( "flea.csrf" )

local function print_account( user, request, enabled )
	local toggle_link = enabled and "/accounts/disable" or "/accounts/enable"
	local toggle_text = enabled and "Disable" or "Enable"

	request:html( function( html )
		return html.div( {
			user.username,
			" ",

			html.form( { method = "post", action = toggle_link, style = "display: inline" }, {
				csrf.token( request, html ),
				html.input( { name = "user_id", type = "hidden", value = user.id } ),
				html.input( { type = "submit", value = toggle_text } ),
			} ),
			" ",

			function( add )
				if request.user.id ~= user.id then
					add(
						html.form( { method = "post", action = "/accounts/reset", style = "display: inline" }, {
							csrf.token( request, html ),
							html.input( { name = "user_id", type = "hidden", value = user.id } ),
							html.input( { type = "submit", value = "Reset password" } ),
						} )
					)
				end
			end,
		} )
	end )
end

return function( request )
	request:write( "<h1>Accounts</h1>" )

	if request.get.newuser then
		request:write( "Account created! Tell them their password is: " )
		request:html( function( html )
			return html.strong( request.get.newuser )
		end )
	elseif request.get.exists then
		request:write( "That account already exists." )
	elseif request.get.enabled then
		request:write( "That account has been enabled." )
	elseif request.get.disabled then
		request:write( "That account has been disabled." )
	elseif request.get.reset then
		request:write( "Their password has been reset to " )
		request:html( function( html )
			return html.strong( request.get.reset )
		end )
		request:write( "." )
	elseif request.get.password then
		request:write( "Your password has been changed." )
	elseif request.get.badpassword then
		request:write( "Try a password that isn't horrible." )
	end

	request:write( "<h2>Change password</h2>" )

	request:html( function( html )
		return html.form( { method = "post", action = "/accounts/password" }, {
			csrf.token( request, html ),
			html.input( { name = "password", type = "password" } ),
			html.input( { name = "redirect", type = "hidden", value = "/accounts?password" } ),
			html.input( { type = "submit", value = "Change password" } ),
		} )
	end )

	request:write( "<h2>Create account</h2>" )

	request:html( function( html )
		return html.form( { method = "post", action = "/accounts/add" }, {
			csrf.token( request, html ),
			"Username: ",
			html.input( { name = "username", type = "text" } ),
			html.input( { type = "submit", value = "Create account" } ),
		} )
	end )

	request:write( "<h2>Active</h2>" )

	for user in db( [[
		SELECT id, username
		FROM users
		WHERE enabled = 1
		ORDER BY username COLLATE NOCASE
	]] ) do
		print_account( user, request, true )
	end

	request:write( "<h2>Inactive</h2>" )

	for user in db( [[
		SELECT id, username
		FROM users
		WHERE enabled = 0
		ORDER BY username COLLATE NOCASE
	]] ) do
		print_account( user, request, false )
	end
end
