-- name: InsertSong :one
INSERT INTO song (title, youtube_id)
VALUES ($1, $2)
RETURNING id, title, youtube_id, created_at;

-- name: GetSong :one
SELECT id, title, youtube_id, created_at
FROM song
WHERE id = $1;

-- name: InsertParticipant :one
INSERT INTO participant (name, phone_e164)
VALUES ($1, $2)
RETURNING id, name, phone_e164, created_at;

-- name: GetParticipant :one
SELECT id, name, phone_e164, created_at
FROM participant
WHERE id = $1;

-- name: UpsertSongRating :one
INSERT INTO song_rating (song_id, rating, rd)
VALUES ($1, $2, $3)
ON CONFLICT (song_id)
DO UPDATE SET rating = EXCLUDED.rating, rd = EXCLUDED.rd
RETURNING song_id, rating, rd;

-- name: InsertBallotSend :one
INSERT INTO ballot_send (participant_id, song_ids)
VALUES ($1, $2)
RETURNING id, participant_id, song_ids, sent_at;

-- name: InsertSMSInbound :one
INSERT INTO sms_inbound (participant_id, body)
VALUES ($1, $2)
RETURNING id, participant_id, body, received_at;

-- name: InsertPairwiseResults :copyfrom
INSERT INTO pairwise_result (winner, loser, created_at)
VALUES ($1, $2, $3);

-- name: Leaderboard :many
SELECT s.id, s.title, sr.rating, sr.rd
FROM song s
JOIN song_rating sr ON s.id = sr.song_id
ORDER BY sr.rating DESC, sr.rd ASC, s.title ASC;

-- name: FetchCandidatesByRD :many
SELECT s.id, s.title, sr.rating, sr.rd
FROM song s
JOIN song_rating sr ON s.id = sr.song_id
WHERE sr.rating BETWEEN $1 AND $2
ORDER BY sr.rd DESC
LIMIT $3;

-- name: FetchLeastSeenSongs :many
SELECT s.id, s.title, COALESCE(b.cnt, 0) AS seen
FROM song s
LEFT JOIN (
    SELECT unnest(song_ids) AS song_id, count(*) AS cnt
    FROM ballot_send
    WHERE participant_id = $1 AND sent_at >= now() - interval '14 days'
    GROUP BY song_id
) b ON s.id = b.song_id
ORDER BY COALESCE(b.cnt,0) ASC, s.id ASC
LIMIT $2;
