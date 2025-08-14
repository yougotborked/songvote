package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"

	"songvote/internal/store"
)

func main() {
	dbURL := os.Getenv("DB_URL")
	if dbURL == "" {
		dbURL = "postgres://postgres:postgres@localhost:5432/bandrank?sslmode=disable"
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatalf("pool connect: %v", err)
	}
	defer pool.Close()

	q := store.New(pool)

	for i := 1; i <= 20; i++ {
		title := fmt.Sprintf("Song %d", i)
		yt := fmt.Sprintf("yt%03d", i)
		if _, err := q.InsertSong(ctx, store.InsertSongParams{Title: title, YoutubeID: yt}); err != nil {
			log.Fatalf("insert song %d: %v", i, err)
		}
		if _, err := q.UpsertSongRating(ctx, store.UpsertSongRatingParams{SongID: int32(i), Rating: 1500, Rd: 350}); err != nil {
			log.Fatalf("insert rating %d: %v", i, err)
		}
	}

	for i := 1; i <= 6; i++ {
		name := fmt.Sprintf("Participant %d", i)
		phone := fmt.Sprintf("+1555000%03d", i)
		if _, err := q.InsertParticipant(ctx, store.InsertParticipantParams{Name: name, PhoneE164: phone}); err != nil {
			log.Fatalf("insert participant %d: %v", i, err)
		}
	}

	log.Println("seed complete")
}
