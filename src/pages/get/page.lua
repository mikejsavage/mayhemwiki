local db = require( "db" )
local markdown = require( "markdown" )

local function select_revision( title, revision )
	if not revision then
		return db:first( [[
			SELECT r.contents
			FROM pages AS p, revisions AS r
			WHERE p.title = ? AND p.revision_id = r.id
		]], title )
	end

	return db:first( [[
		SELECT contents
		FROM revisions
		WHERE title = ? AND id = ?
	]], title, revision )
end

return function( request, title, revision )
	local page = select_revision( title, revision )

	request:html( function( html )
		return html.div( {
			html.strong( title .. ":" ),
			" ",
			html.a( { href = "/" .. title .. "/edit" }, "[edit]" ),
			" ",
			html.a( { href = "/" .. title .. "/history" }, "[history]" ),
			" ",
		} )
	end )

	if page then
		request:write( markdown.render( page.contents ) )
	end
end
