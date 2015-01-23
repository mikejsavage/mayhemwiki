-- grammar:
--
-- HEADERS
-- # h1
-- ## h2 etc
--
-- LISTS
-- - item1
-- - item2
--
-- LINKS
-- [link text](url)
-- !(image url)
-- {OtherPage}

local _M = { }

function _M.render( str )
	str = str:html_escape()
	str = str:gsub( "\r", "" )

	str = ( "\n" .. str ):gsub( "\n(##?#?#?#?)(%s*)([^\n]+)", function( hashes, space, header )
		local tag = "h" .. hashes:len()

		return "<" .. tag .. ">" .. header .. "</" .. tag .. ">"
	end )

	str = ( str .. "\n\n" ):gsub( "(.-)\n\n+", "<p>%1</p>" )

	-- TODO: lists

	str = str:gsub( "!(%b[])", function( url )
		url = url:sub( 2, -2 )
		return "<img src=\"" .. url:url_escape() .. "\">"
	end )

	str = str:gsub( "(%b[])(%b())", function( text, url )
		text = text:sub( 2, -2 )
		url = url:sub( 2, -2 )

		return "<a href=\"" .. url:url_escape() .. "\">" .. text .. "</a>"
	end )

	str = str:gsub( "(%b{})", function( page )
		page = page:sub( 2, -2 )

		return "<a href=\"/" .. page:url_escape() .. "\" style=\"font-weight: bold\">" .. page .. "</a>"
	end )

	return str
end

return _M
