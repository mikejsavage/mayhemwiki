local _M = { }

function _M.css( css )
	return css
		:gsub( ":%s+", ":" )
		:gsub( "\n", "" )
		:gsub( "%s+{", "{" )
		:gsub( "\t", "" )
end

return _M
