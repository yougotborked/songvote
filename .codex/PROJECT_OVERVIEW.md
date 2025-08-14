## bandrank — Project Overview

**Purpose:**\
A daily-drip, SMS-based ranked-choice voting system for prioritizing songs to learn in a band’s repertoire. Uses 3-song micro-ballots to collect preferences, updating a live leaderboard over time.

### Core Features

- SMS ballots (3 random songs per day/person)
- Parsing of replies into ranked choices (supports ties)
- Conversion into pairwise results for ranking
- Elo+RD rating model for leaderboard
- Admin static UI to view rankings
- Sampling logic to maximize information gain
- STOP/HELP keyword compliance

### Stack

- Go 1.22, Fiber v2
- Postgres 16 (Docker)
- sqlc, golang-migrate
- zerolog logging
- Twilio SMS integration (extensible to Telnyx)
- Docker Compose for dev/prod orchestration

### Data Flow

1. **Scheduler** → sends ballots via SMS
2. **Participant Reply** → inbound webhook receives & parses
3. **Parser** → generates pairwise results
4. **Ranking Engine** → updates song ratings
5. **Leaderboard** → served over HTTP API & static UI

### Deployment Targets

- Local dev: docker-compose + ngrok
- Production: containerized, env-configured

### MVP Scope

- Twilio SMS provider
- Randomized sampling with exposure limits
- Elo+RD rating
- Basic static admin leaderboard

### Future Extensions

- Telnyx provider
- Web ballots (mobile-friendly link)
- Bradley-Terry or TrueSkill ranking
- Gamification for engagement