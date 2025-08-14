## bandrank Codex Agent Guide

This document defines:

- Project context
- Agent responsibilities
- Task dependencies
- Dev environment capabilities
- Rules for building, running, testing, and containerizing

---

## 1. Project Context

**Goal:**\
bandrank is a Go service that runs daily SMS-based "micro-ballots" to collect ranked preferences on songs and produces a live leaderboard using an Elo+RD ranking system.\
Participants get 3-song ballots via SMS (Twilio first, Telnyx optional later). Replies are parsed into pairwise results and fed into the ranking engine.

**Stack:**

- **Go 1.22**
- **Fiber v2** (HTTP server)
- **Postgres 16** (Dockerized)
- **golang-migrate** (DB migrations)
- **sqlc** (typed query layer)
- **zerolog** (structured logging)
- **Twilio SDK for Go** (SMS integration)
- **Docker Compose** (dev & prod orchestration)
- **Makefile** for build/test tasks

**Core Entities:**

- `song`
- `participant`
- `ballot_send`
- `sms_inbound`
- `pairwise_result`
- `song_rating`

**SMS Flow:**

1. Scheduler sends 3-song ballot to each active participant.
2. Inbound webhook parses replies and emits pairwise results.
3. Ranking engine updates Elo ratings and RD for each song.
4. Leaderboard endpoint serves sorted song list.

---

## 2. Agent Roles & Dependencies

**Dependency Map:** (see `.codex/AGENT_DEPENDENCIES.json` for machine-readable)

- 1 → none
- 2 → 1
- 3 → 1, 2
- 4 → 1, 3
- 5 → 1, 3
- 6 → 1, 5
- 7 → 2
- 8 → 1, 2, 3, 4, 5, 6, 7
- 9 → 1, 2, 3, 4, 5, 6
- 10 → 3

---

### Agent 1 — Database & sqlc

**Provides:** schema, migrations, generated store\
**Capabilities:**

- Write SQL migrations in `migrations/`
- Define schema for all tables with indexes
- Create `sqlc.yaml`
- Generate Go models & store methods in `internal/store`
- Seed DB with example data

### Agent 2 — HTTP Server, Routing, Config, Logging

**Depends:** Agent 1\
**Capabilities:**

- Create `cmd/server/main.go`
- Wire Fiber routes, middleware, config loader
- Implement API endpoints for participants, songs, leaderboard, send-batch, debug
- Use `internal/store`

### Agent 3 — SMS Provider Interface + Twilio Adapter

**Depends:** Agent 1, Agent 2\
**Capabilities:**

- Implement `SMSProvider` interface
- Send outbound SMS via Twilio
- Parse inbound Twilio webhooks
- Implement fake provider for local testing

### Agent 4 — Ballot Builder & Send Workflow

**Depends:** Agent 1, Agent 3\
**Capabilities:**

- Select 3 songs per participant using sampling logic
- Persist `ballot_send` and call SMS provider
- Prevent duplicate ballot combos within 7 days

### Agent 5 — Inbound Webhook, Reply Parser, Pairwise Emission

**Depends:** Agent 1, Agent 3\
**Capabilities:**

- Parse replies (numbers, letters, ties, titles)
- Match to recent `ballot_send`
- Store `sms_inbound`
- Emit `pairwise_result`
- Handle STOP/HELP compliance

### Agent 6 — Ranking Engine (Elo+RD) and Updater Worker

**Depends:** Agent 1, Agent 5\
**Capabilities:**

- Apply pairwise results to update ratings
- Adjust RD dynamically
- Nightly job to increment RD for idle songs

### Agent 7 — Admin Static UI

**Depends:** Agent 2\
**Capabilities:**

- Build static HTML/JS page under `web/admin`
- Fetch leaderboard JSON and display in table
- Auto-refresh every 60s

### Agent 8 — DevOps: Docker, Compose, Makefile, README

**Depends:** All prior\
**Capabilities:**

- Multi-stage Dockerfile for Go build
- docker-compose.yml for server + Postgres
- Makefile for build/test/lint/migrate
- README for local & prod usage

### Agent 9 — QA: Black-box Tests & Fixtures

**Depends:** Agents 1–6\
**Capabilities:**

- End-to-end tests with `httptest`
- Parser fuzz tests
- Simulate inbound/outbound SMS

### Agent 10 — Optional: Telnyx Adapter

**Depends:** Agent 3\
**Capabilities:**

- Implement Telnyx send & inbound parse
- Config switch for provider

---

## 3. Dev Environment Capabilities for Codex

Codex **can**:

- Write/edit files in repo
- Run shell commands
- Build Go (`go build ./...`)
- Run Go tests (`go test ./...`)
- Build Docker images (`docker build .`)
- Run docker-compose (`docker compose up`)
- Apply migrations (`make migrate_up`)
- Lint (`golangci-lint run`)
- Execute HTTP requests to local services
- Start ngrok tunnel for webhook testing

Codex **cannot**:

- Send actual SMS outside of Twilio test mode
- Make arbitrary external API calls in live mode

---

## 4. Running the Project

```bash
# Start DB & server in Docker
docker compose up --build

# Run migrations
make migrate_up

# Seed data
go run cmd/seed/main.go

# Run locally without Docker
make run

# Run tests
make test

# Lint
make lint
```

---

## 5. Notes for Codex Agents

- Always run `make sqlc` after changing SQL queries.
- Use `SMS_PROVIDER=fake` for tests.
- Twilio outbound should use **test credentials** in `.env`.
- Keep migrations backward-compatible; update `down` scripts.
- No secrets in code — load from env.