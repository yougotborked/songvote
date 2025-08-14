package store_test

import (
	"context"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"songvote/internal/store"
)

func testDB(t *testing.T) *store.Queries {
	t.Helper()
	dbURL := os.Getenv("DB_URL")
	if dbURL == "" {
		dbURL = "postgres://postgres:postgres@localhost:5432/bandrank?sslmode=disable"
	}
	pool, err := pgxpool.New(context.Background(), dbURL)
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	t.Cleanup(func() { pool.Close() })
	return store.New(pool)
}

func TestInsertAndGetSong(t *testing.T) {
	q := testDB(t)
	ctx := context.Background()
	s, err := q.InsertSong(ctx, store.InsertSongParams{Title: "Test Song", YoutubeID: "test-yt"})
	if err != nil {
		t.Fatalf("insert song: %v", err)
	}
	got, err := q.GetSong(ctx, s.ID)
	if err != nil {
		t.Fatalf("get song: %v", err)
	}
	if got.ID != s.ID {
		t.Fatalf("expected %d got %d", s.ID, got.ID)
	}
}

func TestUpsertSongRating(t *testing.T) {
	q := testDB(t)
	ctx := context.Background()
	s, err := q.InsertSong(ctx, store.InsertSongParams{Title: "Rated", YoutubeID: "rated-yt"})
	if err != nil {
		t.Fatalf("insert song: %v", err)
	}
	r, err := q.UpsertSongRating(ctx, store.UpsertSongRatingParams{SongID: s.ID, Rating: 1600, Rd: 100})
	if err != nil {
		t.Fatalf("upsert: %v", err)
	}
	if r.SongID != s.ID {
		t.Fatalf("rating song mismatch")
	}
}
