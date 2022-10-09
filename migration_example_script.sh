#!/bin/zsh
# shellcheck disable=SC2016

CONNECTION_STRING='postgres://lukeoleson:@localhost:5432/users?sslmode=disable'

###############################################################################
printf '===================================================================\n'
printf 'Test 1 - The first migration is valid and gets applied successfully\n'
printf '===================================================================\n\n'
###############################################################################

# 1
printf '--> Note that the DB has no tables\n'
printf '$ echo "\dt" | psql -d users\n'
echo "\dt" | psql -d users
printf '\n'

# 2
printf '--> Migrate the first migration into the DB\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations up\n'
migrate -database "$CONNECTION_STRING" -path migrations goto 1
printf '\n'

# 3
printf '--> The DB now has two tables, "users" and "schema_migrations"\n'
printf 'users=# \dt\n'
echo "\dt" | psql -d users
printf '\n'

# 4
printf '--> "schema_migrations" has a single row where the "version" is taken from the migration filename and "dirty" is false\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users

###################################################################################
printf '=========================================================================\n'
printf 'Test 2 - The second migration has invalid SQL syntax and fails to migrate\n'
printf '=========================================================================\n'
###################################################################################

# 1
printf '--> Migrate the second migration into the DB\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations up\n'
migrate -database "$CONNECTION_STRING" -path migrations goto 2
printf '\n'

# 2
printf '--> Nothing was applied to the DB, so there is nothing to manually fix"\n'
printf 'users=# \dt\n'
echo "\dt" | psql -d users
printf '\n'

# 3
printf '--> The database is now "dirty" and has the "version" of the failed migration\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users

# 4
printf '--> Force the schema_migration back to the last migration\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations force 1\n'
migrate -database "$CONNECTION_STRING" -path migrations force 1
printf '\n'

# 5
printf '--> The database is now "clean" and has the "version" of the last successful migration\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users

#6
printf '--> Fix the invalid migration\n'
printf 'cat > migrations/000002_create_accounts_table.up.sql < fixtures/migration_2_after.txt'
cat > migrations/000002_create_accounts_table.up.sql < fixtures/migration_2_after.txt
printf '\n'

#7
printf '--> Retry the second migration\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations up\n'
migrate -database "$CONNECTION_STRING" -path migrations goto 2
printf '\n'

# 8
printf '--> The database now has the changes from the second migration\n'
printf 'users=# \dt\n'
echo "\dt" | psql -d users
printf '\n'

#9
printf '--> The schema_migrations table is now "clean" and has the latest "version"\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users

####################################################################################
printf '==========================================================================\n'
printf 'Test 3 - The third migration has invalid SQL syntax and partially migrates\n'
printf '==========================================================================\n'
####################################################################################

# 1
printf '--> Migrate the third migration into the DB\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations up\n'
migrate -database "$CONNECTION_STRING" -path migrations goto 3
printf '\n'

# 2
printf '--> The contacts table was created, but not the opportunities table"\n'
printf 'users=# \dt\n'
echo "\dt" | psql -d users
printf '\n'

# 3
printf '--> The database is now "dirty" and has the "version" of the failed migration\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users

# 4
printf '--> Fix the partially applied DB change (note the error here, this was not partially applied, but just as an example)\n'
printf 'users=# drop table contacts;\n'
echo "drop table contacts;" | psql -d users
printf '\n'

#5
printf '--> Note that the DB is back where it was before the partial migration\n'
printf 'users=# \dt\n'
echo "\dt" | psql -d users
printf '\n'

#6
printf '--> Force the schema_migration back to the last migration\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations force 2\n'
migrate -database "$CONNECTION_STRING" -path migrations force 1
printf '\n'

#7
printf '--> Fix the invalid migration\n'
printf 'cat > migrations/000003_create_contacts_table.up.sql < fixtures/migration_3_after.txt'
cat > migrations/000003_create_contacts_table.up.sql < fixtures/migration_3_after.txt
printf '\n\n'

# 8
printf '--> Retry the third migration\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations up\n'
migrate -database "$CONNECTION_STRING" -path migrations goto 3
printf '\n'

# 9
printf '--> The database now has the changes from the third migration\n'
printf 'users=# \dt\n'
echo "\dt" | psql -d users
printf '\n'

# 10
printf '--> The schema_migrations table is now "clean" and has the latest "version"\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users


############################################################################
printf '=================================================================\n'
printf 'Test 4 - The fourth migration has a typo and needs to be replaced\n'
printf '=================================================================\n'
############################################################################

# 1
printf '--> Migrate the fourth migration into the DB\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations up\n'
migrate -database "$CONNECTION_STRING" -path migrations goto 4
printf '\n'

# 2
printf '--> The leeds table was created (note the typo)"\n'
printf 'users=# \dt\n'
echo "\dt" | psql -d users
printf '\n'

# 3
printf '--> The database is, of course, clean with the correct version\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users

# 4
printf '--> Roll back to the last version\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations down 1\n'
migrate -database "$CONNECTION_STRING" -path migrations down 1
printf '\n'

# 7
printf '--> The leeds table is gone, but everything else remains"\n'
printf 'users=# \dt\n'
echo "\dt" | psql -d users
printf '\n'

#8
printf '--> Fix the invalid migration\n'
printf 'cat > migrations/000004_create_leads_table.up.sql < fixtures/migration_4_after.txt\n'
printf 'cat > migrations/000004_create_leads_table.down.sql < fixtures/migration_4_down_after.txt\n'
cat > migrations/000004_create_leads_table.up.sql < fixtures/migration_4_after.txt
cat > migrations/000004_create_leads_table.down.sql < fixtures/migration_4_down_after.txt
printf '\n\n'

# 9
printf '--> The database version is rolled back 1 migration\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users

# 10
printf '--> Redo the fourth migration\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations up\n'
migrate -database "$CONNECTION_STRING" -path migrations goto 4
printf '\n'

# 9
printf '--> The database now has the changes from the fourth migration\n'
printf 'users=# \dt\n'
echo "\dt" | psql -d users
printf '\n'

# 10
printf '--> The schema_migrations table is now has the latest "version"\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users

#########################################################################################################
printf '==============================================================================================\n'
printf 'Test 5 - The fifth and sixth migrations are migrated in out of order (async development issue)\n'
printf '==============================================================================================\n'
#########################################################################################################

# 1
printf '--> Migrate the sixth migration in before the fifth\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations up\n'
migrate -database "$CONNECTION_STRING" -path migrations goto 6
printf '\n'

# 2
printf '--> The payments table is created"\n'
printf 'users=# \dt\n'
echo "\dt" | psql -d users
printf '\n'

# 3
printf '--> The database is, of course, clean with the correct version\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users

# 4
printf '--> "merge" in the fifth migration in now (after the sixth)\n'
printf '$ cp fixtures/000005_create_activities_table.* migrations/\n'
cp fixtures/000005_create_activities_table.* migrations/
printf '$ migrate -database $CONNECTION_STRING -path migrations up\n'
migrate -database "$CONNECTION_STRING" -path migrations goto 6
printf '\n'

# 5
printf '--> The database is still clean with the "correct" version\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users

# 6
printf '--> However, the activities table (migration #5) was not applied"\n'
printf 'users=# \dt\n'
echo "\dt" | psql -d users
printf '\n'

# 7
printf '--> Fix the migration mis-ordering\n'
printf 'mv migrations/000005_create_activities_table.up.sql migrations/000007_create_activities_table.up.sql\n'
printf 'mv migrations/000005_create_activities_table.down.sql migrations/000007_create_activities_table.down.sql\n'
mv migrations/000005_create_activities_table.up.sql migrations/000007_create_activities_table.up.sql
mv migrations/000005_create_activities_table.down.sql migrations/000007_create_activities_table.down.sql
printf '\n\n'

# 8
printf '--> Rerun the migration\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations up\n'
migrate -database "$CONNECTION_STRING" -path migrations goto 7
printf '\n'

# 9
printf '--> The activities table is now there"\n'
printf 'users=# \dt\n'
echo "\dt" | psql -d users
printf '\n'

# 10
printf '--> The database version is updated to 7 and is clean\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users

#######################################################################
printf '=============================================================\n'
printf 'Test 6 - Make changes to a previously deployed migration file\n'
printf '=============================================================\n'
#######################################################################

# 1
printf '--> Modify a deployment that has already been successfully deployed\n'
printf 'cat > migrations/000007_create_activities_table.up.sql < fixtures/000005_create_activities_table_2.up.sql\n'
cat > migrations/000007_create_activities_table.up.sql < fixtures/000005_create_activities_table_2.up.sql
printf '\n\n'

#2
printf '--> Apply the migrations\n'
printf '$ migrate -database $CONNECTION_STRING -path migrations up\n'
migrate -database "$CONNECTION_STRING" -path migrations goto 7
printf '\n'

# 3
printf '--> The database is clean with the same version number\n'
printf 'users=# select * from schema_migrations;\n'
echo "select * from schema_migrations;" | psql -d users

# 4
printf '--> The activities table is unchanged"\n'
printf 'users=# \dt\n'
echo "select * from activities" | psql -d users
printf '\n'

# Clean up
#cat > migrations/000007_create_activities_table.up.sql < fixtures/000005_create_activities_table.up.sql

#
# Reset everything
#
cat > migrations/000002_create_accounts_table.up.sql < fixtures/migration_2_before.txt
cat > migrations/000003_create_contacts_table.up.sql < fixtures/migration_3_before.txt
cat > migrations/000004_create_leads_table.up.sql < fixtures/migration_4_before.txt
cat > migrations/000004_create_leads_table.down.sql < fixtures/migration_4_down_before.txt

migrate -database "$CONNECTION_STRING" -path migrations down -all
echo "drop table schema_migrations;" | psql -d users
echo "drop table leads;" | psql -d users

rm migrations/000007_create_activities_table.*
