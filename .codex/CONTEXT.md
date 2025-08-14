Master Context

Goal: Create a distributed ranked-choice voting system via SMS to prioritize songs for a band’s repertoire. Participants get small daily ballots, results accumulate into a live, statistically robust ranking.

Stack:

Go 1.22

Fiber v2

Postgres 16

sqlc

golang-migrate

zerolog

Twilio SDK

Docker Compose

Flow:

Scheduler chooses 3 songs per participant using sampling rules.

Outbound SMS includes numbered YouTube links.

Inbound webhook parses ranking replies into pairwise comparisons.

Ranking engine updates ratings and RD.

Leaderboard API + UI shows sorted list by rating.

Constraints:

SMS-only MVP, web ballots optional later

Twilio test credentials for development

Compliance with STOP/HELP

Modular design for adding other providers like Telnyx

Architecture at a Glance

SMS Provider (Twilio / Telnyx) for sending and receiving messages

Go API Service (Fiber) handles sending batches, processing replies, and exposing leaderboard

Ranking Engine applies pairwise updates to Elo+RD ratings

PostgreSQL Database stores songs, participants, ballots, pairwise results, and ratings

Scheduler sends daily ballots and manages non-responder cadence

Admin UI (static HTML/JS) fetches and displays the leaderboard

Docker Compose orchestrates local development with Postgres and API container

Detailed Components

SMS Provider Layer

Abstract interface for sending/receiving SMS

Twilio adapter first, Telnyx planned

Fake provider for local tests

API Service

REST endpoints for participants, songs, leaderboard, and inbound webhooks

Fiber middleware for logging, panic recovery, and request IDs

Ballot Builder

Sampling strategy for song selection: top RD, mid RD, and low-exposure songs

Prevent duplicate ballots within 7 days per participant

Reply Parser

Accepts numeric, alphabetic, and tied rankings

Handles variations in separators and formats

Produces pairwise results with tie strengths

Ranking Engine

Elo with rating deviation (RD) adjustment

Dynamic K-factor based on uncertainty

Nightly RD increment for idle songs

Data Storage

Postgres schema for songs, participants, ballots, inbound SMS, pairwise results, and ratings

sqlc for type-safe queries

golang-migrate for schema management

Admin UI

Static HTML/JS fetching leaderboard from API

Auto-refresh every 60 seconds

DevOps

Docker Compose setup for API and Postgres

Makefile for build, migrate, lint, and test

Ngrok integration for webhook testing

Data Flow Summary

Daily Scheduler triggers ballot creation.

Ballot Builder selects songs and sends via SMS Provider.

Participant Reply hits inbound webhook.

Parser generates pairwise results.

Ranking Engine updates ratings.

Leaderboard API serves latest rankings to Admin UI.

MVP Scope

Twilio SMS provider

Randomized sampling with exposure limits

Elo+RD rating

Basic static admin leaderboard

Future Extensions

Telnyx provider

Web ballots (mobile-friendly link)

Bradley-Terry or TrueSkill ranking

Gamification for engagement