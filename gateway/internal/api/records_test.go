package api_test

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"

    "github.com/gorilla/mux"
    "github.com/yourname/kontena/gateway/internal/api"
    "github.com/yourname/kontena/gateway/internal/db"
)

func setup(t *testing.T) (*mux.Router, *db.DB) {
    database, err := db.Open(":memory:")
    if err != nil {
        t.Fatal(err)
    }
    r := mux.NewRouter()
    r.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
        w.WriteHeader(200)
    })
    api.RegisterRoutes(r, database)
    return r, database
}

func TestCreateAndList(t *testing.T) {
    r, database := setup(t)
    defer database.Close()

    body, _ := json.Marshal(map[string]interface{}{
        "id": "test1", "schema": "word", "lang_code": "kri",
        "payload": "pɔsin", "device_id": "dev1",
        "created_at": 1000, "updated_at": 1000,
    })
    req := httptest.NewRequest("POST", "/records", bytes.NewBuffer(body))
    req.Header.Set("Content-Type", "application/json")
    w := httptest.NewRecorder()
    r.ServeHTTP(w, req)
    if w.Code != 201 {
        t.Errorf("expected 201, got %d", w.Code)
    }

    req2 := httptest.NewRequest("GET", "/records?schema=word", nil)
    w2 := httptest.NewRecorder()
    r.ServeHTTP(w2, req2)
    if w2.Code != 200 {
        t.Errorf("expected 200, got %d", w2.Code)
    }

    var records []map[string]interface{}
    json.Unmarshal(w2.Body.Bytes(), &records)
    if len(records) != 1 {
        t.Errorf("expected 1 record, got %d", len(records))
    }
}
