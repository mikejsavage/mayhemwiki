local bcrypt = require( "bcrypt" )

local sqlite = require( "flea.sqlite" )

local db = sqlite.open( config.db_path )

db:run( [[ CREATE TABLE IF NOT EXISTS users (
	id INTEGER PRIMARY KEY,
	username STRING UNIQUE NOT NULL,
	password STRING NOT NULL,
	change_password INTEGER NOT NULL DEFAULT 1,
	enabled INTEGER NOT NULL DEFAULT 1
) ]] )

db:run( [[ CREATE TABLE IF NOT EXISTS revisions (
	id INTEGER PRIMARY KEY,
	date INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP,
	author INTEGER NOT NULL,
	title STRING NOT NULL,
	contents STRING NOT NULL,
	FOREIGN KEY ( author ) REFERENCES users ( id )
) ]] )

db:run( "CREATE INDEX IF NOT EXISTS idx_revisions_title ON revisions ( title )" )

-- indexes!

db:run( [[ CREATE TABLE IF NOT EXISTS pages (
	title STRING NOT NULL UNIQUE ON CONFLICT REPLACE,
	revision_id INTEGER,
	FOREIGN KEY ( revision_id ) REFERENCES revisions ( id )
) ]] )

db:run( "CREATE INDEX IF NOT EXISTS idx_pages_revision_id ON pages ( revision_id )" )

db:run( "PRAGMA foriegn_keys = ON" )

return db
