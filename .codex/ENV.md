## bandrank Environment Reference

### Language & Tools

- Go 1.22.x
- Fiber v2
- sqlc v1.23+
- golang-migrate v4.x
- zerolog v1.x
- golangci-lint v1.54+
- Docker Engine 24.x
- docker-compose plugin v2.x
- ngrok (latest)

### Database

- Postgres 16 (Docker image: postgres:16-alpine)
- Default ports: host 5432 → container 5432
- Default creds: `postgres` / `postgres`

### Environment Variables

```env
PORT=8080
DB_URL=postgres://postgres:postgres@db:5432/bandrank?sslmode=disable
SMS_PROVIDER=twilio       # or fake
TWILIO_ACCOUNT_SID=ACxxxx
TWILIO_AUTH_TOKEN=xxxx
TWILIO_MESSAGING_SERVICE_SID=MGxxxx
BASE_URL=http://localhost:8080
TIMEZONE_DEFAULT=America/Chicago
```

### Networking

- HTTP API: `http://localhost:8080`
- Admin UI: `http://localhost:8080/admin`
- Webhook: `http://localhost:8080/sms/inbound/twilio` (ngrok for external)

### Twilio Test Credentials

- Use Twilio's official test SID & token for development
- Avoid sending live SMS in dev

### Ports Used

- 8080 (API/UI)
- 5432 (Postgres)

---