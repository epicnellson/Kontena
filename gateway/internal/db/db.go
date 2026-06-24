package db

import (
    "database/sql"
    _ "modernc.org/sqlite"
)

type DB struct {
    *sql.DB
}

func Open(path string) (*DB, error) {
    d, err := sql.Open("sqlite", path+"?_journal_mode=WAL&_foreign_keys=on")
    if err != nil {
        return nil, err
    }
    if err := d.Ping(); err != nil {
        return nil, err
    }
    if err := migrate(d); err != nil {
        return nil, err
    }
    return &DB{d}, nil
}

func migrate(d *sql.DB) error {
    _, err := d.Exec(`
        CREATE TABLE IF NOT EXISTS records (
            id         TEXT PRIMARY KEY,
            schema     TEXT NOT NULL,
            lang_code  TEXT NOT NULL DEFAULT '',
            payload    TEXT NOT NULL DEFAULT '',
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            device_id  TEXT NOT NULL DEFAULT '',
            hop_count  INTEGER NOT NULL DEFAULT 0
        );
        CREATE INDEX IF NOT EXISTS idx_records_schema ON records(schema);
        CREATE INDEX IF NOT EXISTS idx_records_updated ON records(updated_at);
    `)
    return err
}
