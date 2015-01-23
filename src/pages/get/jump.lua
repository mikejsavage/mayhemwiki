return function( request )
	request:redirect( "/" .. request.get.title or "" )
end
