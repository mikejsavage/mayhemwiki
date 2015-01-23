#! /usr/bin/lua

config = { db_path = "db.sq3", secret_path = "secret.bin", bcrypt_rounds = 8 }

local flea = require( "flea" )
local time = require( "flea.time" )

local db = require( "db" )
local minify = require( "minify" )

if not db:first( "SELECT 1 FROM users" ) then
	print( "You don't have any accounts. Run new_account.lua to create one." )
	os.exit( 1 )
end

local function serialize_user_to_cookie( request, user )
	local serialized = json.encode( user )

	request:set_cookie( "session", serialized, time.days( 30 ) )
end

local login_page = assert( dofile( "pages/get/login.lua" ) )
local function show_login_page( request )
	login_page( request )

	return request:not_authorized()
end

local password_get_page = assert( dofile( "pages/get/password.lua" ) )
local function show_password_get_page( request )
	password_get_page( request )
end

local password_post_page = assert( dofile( "pages/post/password.lua" ) )
local function show_password_post_page( request )
	password_post_page( request )
end

local function make_callback( handler )
	if type( handler ) == "function" then
		return handler
	end

	local path = "pages/" .. handler:gsub( "%.", "/" ) .. ".lua"
	local callback = assert( dofile( path ) )

	return callback
end

local css = minify.css( io.readFile( "style.css" ) )

local function require_auth( handler )
	local callback = make_callback( handler )

	return function( request, ... )
		request:html( function( html )
			return html.meta( { name = "viewport", content = "width=device-width, initial-scale=1" } )
		end )

		if request.cookies.session then
			request.user = db:first( "SELECT * FROM users WHERE id = ? AND enabled = 1", request.cookies.session )
		end

		if not request.user then
			return show_login_page( request )
		end

		if request.user.change_password == 1 then
			if request.method == "get" then
				return show_password_get_page( request )
			end

			return show_password_post_page( request )
		end

		request:html( function( html )
			return html.style( { type = "text/css" }, css )
		end )

		request:html( function( html )
			return html.div[ ".header" ]( {
				html.a( { href = "/index" }, html.b( "mayhemwiki" ) ),
				" ",
				html.a( { href = "/all" }, "all" ),
				" ",
				html.a( { href = "/accounts" }, "accounts" ),
				" ",
				html.a( { href = "/changes" }, "changes" ),
				" ",
				html.a( { href = "/logout" }, "log out " .. request.user.username ),
				" ",

				html.form( { action = "jump", style = "display: inline" }, {
					html.input[ ".jump" ]( { name = "title", type = "text" } ),
					html.input[ ".jump-button" ]( { type = "submit", value = "Jump to page" } ),
				} ),
			} )
		end )

		return callback( request, ... )
	end
end

-- routing
local authenticated_routes = {
	get = {
		{ "", function( request )
			return request:redirect( "/index" )
		end },

		{ "(.+)", "page" },
		{ "(.+)/(.+)", "page" },
		{ "jump", "jump" },
		{ "(.+)/edit", "edit" },
		{ "(.+)/history", "page_history" },

		{ "all", "all" },
		{ "changes", "changes" },

		{ "accounts", "accounts" },
		{ "accounts/password", "password" },

		{ "logout", function( request )
			request:delete_cookie( "session" )
			return request:redirect( "/" )
		end },
	},

	post = {
		{ "(.+)/edit", "page" },

		{ "accounts/add", "accounts_add" },
		{ "accounts/enable", "accounts_enable" },
		{ "accounts/disable", "accounts_disable" },
		{ "accounts/password", "password" },
		{ "accounts/reset", "reset" },
	},
}

for method, routes in pairs( authenticated_routes ) do
	for _, route in ipairs( routes ) do
		local handler = type( route[ 2 ] ) == "function" and route[ 2 ] or method .. "." .. route[ 2 ]
		flea[ method ]( route[ 1 ], require_auth( handler ) )
	end
end

flea.post( "login", make_callback( "post.login" ) )

-- go
flea.run()
