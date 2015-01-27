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

local function render_non_code( str )
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

function _M.render( str )
	str = str:html_escape()
	str = str:gsub( "\r", "" )

	local rendered = { }

	for non_code, ticks, code in ( str .. "``" ):gmatch( "(.-)(`+)(.-)`+" ) do
		table.insert( rendered, render_non_code( non_code ) )

		if ticks:len() == 1 then
			table.insert( rendered, "<code>" .. code .. "</code>" )
		else
			table.insert( rendered, "<pre><code>" .. code .. "</code></pre>" )
		end
	end

	return table.concat( rendered )
end

return _M
