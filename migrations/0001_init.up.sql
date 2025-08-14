CREATE TABLE participant (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    phone_e164 TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE song (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    youtube_id TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE song_rating (
    song_id INTEGER PRIMARY KEY REFERENCES song(id) ON DELETE CASCADE,
    rating DOUBLE PRECISION NOT NULL DEFAULT 1500,
    rd DOUBLE PRECISION NOT NULL DEFAULT 350
);

CREATE TABLE ballot_send (
    id BIGSERIAL PRIMARY KEY,
    participant_id INTEGER NOT NULL REFERENCES participant(id) ON DELETE CASCADE,
    song_ids INTEGER[] NOT NULL,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_ballot_send_participant_sent_at ON ballot_send(participant_id, sent_at);

CREATE TABLE sms_inbound (
    id BIGSERIAL PRIMARY KEY,
    participant_id INTEGER REFERENCES participant(id) ON DELETE SET NULL,
    body TEXT NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE pairwise_result (
    id BIGSERIAL PRIMARY KEY,
    winner INTEGER NOT NULL REFERENCES song(id) ON DELETE CASCADE,
    loser INTEGER NOT NULL REFERENCES song(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_pairwise_result_winner_loser_created_at ON pairwise_result(winner, loser, created_at);
