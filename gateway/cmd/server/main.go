package main

import (
    "log"
    "net/http"
    "encoding/json"

    "github.com/gorilla/mux"
    "github.com/yourname/kontena/gateway/internal/api"
    "github.com/yourname/kontena/gateway/internal/db"
)

func main() {
    database, err := db.Open("kontena.db")
    if err != nil {
        log.Fatalf("failed to open database: %v", err)
    }
    defer database.Close()

    r := mux.NewRouter()
    r.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(map[string]string{"status": "ok", "version": "0.1.0"})
    }).Methods("GET")
    api.RegisterRoutes(r, database)

    log.Println("Gateway listening on :8080")
    log.Fatal(http.ListenAndServe(":8080", r))
}
