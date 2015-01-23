local db = require( "db" )
local csrf = require( "flea.csrf" )

return function( request, title )
	local page = db:first( [[
		SELECT
			r.title, r.date, r.author, r.contents
		FROM
			pages AS p, revisions AS r
		WHERE
			p.title = ? AND p.revision_id = r.id
	]], title )

	request:html( function( html )
		return html.form( { method = "post" }, {
			html.textarea( { style = "width: 100%", rows = 40, name = "contents" }, page and page.contents or "" ),
			csrf.token( request, html ),
			html.br(),
			html.input( { type = "submit", value = "Submit edit" } ),
			" ",
			html.a( { href = "/" .. title }, "Nevermind" ),
		} )
	end )

	request:html( function( html )
		return html.div( {
			html.h3( "Markdown reference" ),
			html.table( {
				html.tr( {
					html.th( "type this" ),
					html.th( "get this" ),
				} ),

				html.tr( {
					html.td( {
						html.code( "# biggest" ), html.br(),
						html.code( "## huge" ), html.br(),
						html.code( "### big" ),
					} ),
					html.td( "Some big text" ),
				} ),

				html.tr( {
					html.td( html.code( "{index}" ) ),
					html.td( html.a( { href = "/index" }, "{index}" ) ),
				} ),

				html.tr( {
					html.td( html.code( "[google](https://www.google.com/)" ) ),
					html.td( html.a( { href = "https://www.google.com/" }, "google" ) ),
				} ),

				html.tr( {
					html.td( html.code( "![https://lh4.google.../glenn+robinson+360+jam.gif]" ) ),
					html.td( html.img( { src = "https://lh4.googleusercontent.com/-DPuhPSbx98U/UPirmoYpkYI/AAAAAAAAAtQ/Nrqeav4HEsY/w497-h373/glenn+robinson+360+jam.gif" } ) ),
				} ),
			} ),
		} )
	end )
end
