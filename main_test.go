package main

import (
	"database/sql"
	"fmt"
	"log"
	"testing"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	_ "github.com/lib/pq"
	"github.com/stretchr/testify/assert"
)

const (
	host     = "localhost"
	port     = 5432
	user     = "lukeoleson"
	password = "pass"
	dbname   = "users"
)

func TestSomething(t *testing.T) {
	db := connectToDB(t)
	defer db.Close()

	runTests(t, db)
}

func connectToDB(t *testing.T) *sql.DB {
	psqlInfo := fmt.Sprintf(
		"host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname,
	)

	db, err := sql.Open("postgres", psqlInfo)
	assert.NoError(t, err)

	err = db.Ping()
	assert.NoError(t, err)

	return db
}

func runTests(t *testing.T, db *sql.DB) {
	migrateFirstChangeToDB(t, db)
}

// migrateFirstChangeToDB Successfully migrates a new table into the DB
// equivalent cmd: migrate -database 'postgres://lukeoleson:@localhost:5432/users?sslmode=disable' -path migrations up
func migrateFirstChangeToDB(t *testing.T, db *sql.DB) {
	// test
	migration, err := migrate.New(
		"file://migrations",
		"postgres://lukeoleson:pass@localhost:5432/users?sslmode=disable")
	assert.NoError(t, err)

	err = migration.Up()
	assert.NoError(t, err)

	// assert
	sqlStatement := `SELECT * FROM schema_migrations`
	rows, err := db.Query(sqlStatement)
	defer rows.Close()
	assert.NoError(t, err)

	schemaVersion, isDirty := getSchemaMigrations(t, rows)

	assert.Equal(t, 20221003024637, schemaVersion)
	assert.Equal(t, false, isDirty)
}

func getSchemaMigrations(t *testing.T, rows *sql.Rows) (int, bool) {
	var version int
	var dirty bool
	for rows.Next() {
		err := rows.Scan(&version, &dirty)
		assert.NoError(t, err)
	}
	assert.NoError(t, rows.Err())

	return version, dirty
}

func down() {
	m, err := migrate.New(
		"file://migrations",
		"postgres://lukeoleson:pass@localhost:5432/users?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}

	if err := m.Down(); err != nil {
		log.Fatal(err)
	}
}
