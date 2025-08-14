## bandrank — SMS-Based Ranked Choice Voting System

**bandrank** is a Go service for running daily SMS-based "micro-ballots" that collect ranked preferences on songs, updating a live leaderboard using an Elo+RD rating system. Participants receive 3-song ballots via SMS, reply with their rankings, and the system processes responses to determine what songs should be learned next.

---

### Features

- **Daily 3-song ballots via SMS**
- **Flexible reply parsing** (supports numeric, letter, and tied rankings)
- **Pairwise result generation** from ranked ballots
- **Elo+RD ranking model** for leaderboard updates
- **Sampling logic** to ensure fairness and maximize data value
- **Admin static UI** for live leaderboard display
- **STOP/HELP compliance** for SMS regulations

---

### Tech Stack

- Go 1.22 + Fiber v2 HTTP server
- PostgreSQL 16 (Dockerized)
- sqlc for type-safe queries
- golang-migrate for migrations
- zerolog for structured logging
- Twilio SMS integration (Telnyx planned)
- Docker Compose for development & deployment

---

### Quickstart

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/bandrank.git
cd bandrank
```

2. **Start services with Docker Compose**

```bash
docker compose up --build
```

3. **Run database migrations**

```bash
make migrate_up
```

4. **Seed the database**

```bash
go run cmd/seed/main.go
```

5. **Access the API & Admin UI**

- API: [http://localhost:8080](http://localhost:8080)
- Admin UI: [http://localhost:8080/admin](http://localhost:8080/admin)

---

### Environment Variables

See `.codex/ENV.md` for full configuration details.

Essential variables:

```env
PORT=8080
DB_URL=postgres://postgres:postgres@db:5432/bandrank?sslmode=disable
SMS_PROVIDER=twilio # or fake for dev
TWILIO_ACCOUNT_SID=ACxxxx
TWILIO_AUTH_TOKEN=xxxx
TWILIO_MESSAGING_SERVICE_SID=MGxxxx
BASE_URL=http://localhost:8080
TIMEZONE_DEFAULT=America/Chicago
```

---

### Development

- **Run locally without Docker:**

```bash
make run
```

- **Run tests:**

```bash
make test
```

- **Lint:**

```bash
make lint
```

---

### Project Structure

- `.codex/AGENTS.md` — detailed agent roles, dependencies, and dev rules
- `.codex/ENV.md` — environment reference
- `.codex/PROJECT_OVERVIEW.md` — high-level project summary
- `internal/` — service code (HTTP, SMS, ranking, sampling)
- `migrations/` — database migrations
- `cmd/` — service and seed entrypoints
- `web/admin/` — static admin UI

---

### License

[MIT](LICENSE)