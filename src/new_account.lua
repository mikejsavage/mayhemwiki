#! /usr/bin/lua

local bcrypt = require( "bcrypt" )

config = { db_path = "db.sq3", secret_path = "secret.bin", bcrypt_rounds = 8 }

local db = require( "db" )
local words = require( "words" )

io.stdout:write( "Pick a username: " )
io.stdout:flush()

local username = io.stdin:read( "*line" )
local password = words.get_random()
local digest = bcrypt.digest( password, config.bcrypt_rounds )

db:run( "INSERT INTO users ( username, password ) VALUES ( ?, ? )", username:lower(), digest )

print( "Your password is: " .. password )
