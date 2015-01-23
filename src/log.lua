local _M = { }

local function log( level )
	local prefix = "[" .. level:upper() .. "] "

	return function( format, ... )
		print( prefix .. format:format( ... ):gsub( "\27", "\\e" ) )
	end
end

_M.info = log( "info" )
_M.warn = log( "warn" )
_M.error = log( "error" )

return _M
