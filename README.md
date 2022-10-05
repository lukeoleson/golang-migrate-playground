# Migration Playground

Run postgresql
```shell
brew services start postgresql
psql -d users
export POSTGRESQL_URL='postgres://postgres:@localhost:5432/example?sslmode=disable'
brew services stop postgresql
```

golang-migrate
```
# Set the env var for the db URL
export POSTGRESQL_URL='postgres://lukeoleson:pass@localhost:5432/postgres?sslmode=disable'
# up
migrate -database ${POSTGRESQL_URL} -path db/migrations up
#down
migrate -database ${POSTGRESQL_URL} -path db/migrations down
```

# Notes
## psql commands
```
\du             #list users
\l              #list databases
\dt             #list tables
\d TABLE_NAME   #describe the table
\c db_name      #connect to a db
```

# To Do
- going out of order
- fixing a dirty database
- idempotent migrations
- what does it do when the database always exists?
- Why do we need all these files?
- What is the migration version number?
- Can you merge a migration out of order and have it succeed?
- What is the real issue with running migrations out of order?
    - You may reference something that doesn't exist.
- What happens if a change a migration?
- What is the difference between a migration that spins up a new db versus existing (cloud)?
- migration check (see NFL and this thread https://github.com/golang-migrate/migrate/issues/179#issuecomment-475821264)
- What happens with missed migrations? Does this throw an error? Why? Who knows that it's not there? Is that the version number? Where does the version number come from?
- Can I write go tests to test this all out?
- Missed migrations:
    - I pull the repo, miss one that is created in someone else's branch, then create my own
- There's a migration table?
- Can I migrate down two versions? And back up?
- migrate -path migrations/ -database postgres://test:test@localhost/dummy?sslmode=disable force 15
- check out migrate --help
- check out schema_migrations
- write an erroneous migration (first lines work, last doesn't), what happens? partial apply? Same thing with a transaction. What happens? Dirty db?
- using transactions (success, fail)
- simulate the scenario where two devs make migrations at the same time, and the newer one gets merged in first.
- applying a version n versions back - do I have to roll back 1 by 1 or can I jump back in time? Is there a command for this or do I just update the db manually?
- can you apply a migration twice?
- what if someone has already added data and the version needs to be rolled back?
- What if someone manually edits the version number?
- What is your mental model of how migrations work?
- What version is left if the migration fails?
- Do I have to manually force the version? Can I manually force a version?
- No changes

# Migration Tests

1. create_users_table up 
- create the user table with a few attributes
- check that it was created successfully: `\d users`
- check that we now have a `schema_migrations` table as well: `\dt`
- check that our db version matches our first (current) migration (version=timestamp from migration filename) and that the db is "clean" (dirty=f): `select * from schema_migrations`
1. create_users_table down
- drop the users table by running the down migration.
- check that it was dropped successfully: `\dt` - should see only the `schema_migrations` table.
- check that there is no version or dirty flag in `schema_migrations`: `select * from schema_migrations`
1. 