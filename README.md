# Migration Playground

## Migration Tests
* The `migration_example_script.sh` applies a number of different migration scenarios.
* The commands printed and the commands executed are not *exactly* the same as we are simulating time passing with each test, so it has to be stopped from applying ALL migrations each time.

## To Do

* Containerize - currently relies on postgres running locally with homebrew with a users database created.
* Change your fixtures to be the original migration files and just cp them into the migrations folder (a tmp folder?) as you need them in the code

## Outstanding Questions

- What happens if a change a migration?
- migration check (see NFL and this thread https://github.com/golang-migrate/migrate/issues/179#issuecomment-475821264)
- What is your mental model of how migrations work?

## commands

Run postgresql
```shell
brew services start postgresql
psql -d users
export POSTGRESQL_URL='postgres://postgres:@localhost:5432/example?sslmode=disable'
brew services stop postgresql
```

Work with psql 
```
\du             #list users
\l              #list databases
\dt             #list tables
\d TABLE_NAME   #describe the table
\c db_name      #connect to a db
```