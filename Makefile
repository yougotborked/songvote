DB_URL ?= postgres://postgres:postgres@localhost:5432/bandrank?sslmode=disable

.PHONY: db_up migrate_up sqlc

db_up:
	docker compose up -d db

migrate_up:
	migrate -path migrations -database $(DB_URL) up

sqlc:
	sqlc generate
