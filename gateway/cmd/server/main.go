package main

import (
    "encoding/json"
    "log"
    "net/http"
    "github.com/gorilla/mux"
)

func main() {
    r := mux.NewRouter()
    r.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(map[string]string{
            "status":  "ok",
            "version": "0.1.0",
            "service": "kontena-gateway",
        })
    }).Methods("GET")
    log.Println("Gateway listening on :8080")
    log.Fatal(http.ListenAndServe(":8080", r))
}
