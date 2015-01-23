local time = require( "flea.time" )

return function( request )
	if request.get.badlogin then
		request:write( "Incorrect username or password." )
	end

	request:html( function( html )
		return html.form( { method = "post", action = "/login" }, {
			html.table( {
				html.tr( {
					html.td( "Username:" ),
					html.td( html.input( { type = "text", name = "username" } ) ),
				} ),
				html.tr( {
					html.td( "Password:" ),
					html.td( html.input( { type = "password", name = "password" } ) ),
				} ),
			} ),
			html.input( { name = "redirect", type = "hidden", value = request.url } ),
			html.input( { type = "submit", value = "Log in" } ),
		} )
	end )
end
