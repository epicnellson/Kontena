package db

import (
    "testing"
)

func TestOpenAndMigrate(t *testing.T) {
    db, err := Open(":memory:")
    if err != nil {
        t.Fatalf("Open failed: %v", err)
    }
    defer db.Close()
    var count int
    db.QueryRow("SELECT COUNT(*) FROM records").Scan(&count)
    if count != 0 {
        t.Errorf("expected 0 records, got %d", count)
    }
}
