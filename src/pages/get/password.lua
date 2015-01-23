local csrf = require( "flea.csrf" )
local time = require( "flea.time" )

return function( request )
	if request.get.badpassword then
		request:write( "Try a password that isn't horrible." )
	end

	request:html( function( html )
		return html.form( { method = "post", action = "/accounts/password" }, {
			csrf.token( request, html ),
			html.tr( {
				html.td( "New password: " ),
				html.td( html.input( { type = "password", name = "password" } ) ),
			} ),
			html.br(),
			html.input( { name = "redirect", type = "hidden", value = request.url } ),
			html.input( { type = "submit", value = "Change password" } ),
		} )
	end )
end
