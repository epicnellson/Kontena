package api

import (
    "database/sql"
    "encoding/json"
    "net/http"
    "time"

    "github.com/gorilla/mux"
    "github.com/yourname/kontena/gateway/internal/db"
)

type Record struct {
    ID        string `json:"id"`
    Schema    string `json:"schema"`
    LangCode  string `json:"lang_code"`
    Payload   string `json:"payload"`
    CreatedAt int64  `json:"created_at"`
    UpdatedAt int64  `json:"updated_at"`
    DeviceID  string `json:"device_id"`
    HopCount  int    `json:"hop_count"`
}

func RegisterRoutes(r *mux.Router, database *db.DB) {
    r.HandleFunc("/records",           createRecord(database)).Methods("POST")
    r.HandleFunc("/records",           listRecords(database)).Methods("GET")
    r.HandleFunc("/records/{id}",      getRecord(database)).Methods("GET")
    r.HandleFunc("/sync/batch",        pullBatch(database)).Methods("GET")
    r.HandleFunc("/sync/batch",        pushBatch(database)).Methods("POST")
}

func createRecord(database *db.DB) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        var rec Record
        if err := json.NewDecoder(r.Body).Decode(&rec); err != nil {
            http.Error(w, `{"error":"invalid JSON"}`, 400)
            return
        }
        if rec.ID == "" || rec.Schema == "" {
            http.Error(w, `{"error":"id and schema required"}`, 400)
            return
        }
        now := time.Now().UnixMilli()
        if rec.CreatedAt == 0 { rec.CreatedAt = now }
        if rec.UpdatedAt == 0 { rec.UpdatedAt = now }

        // Last-write-wins: keep record with higher updated_at
        var existingUpdatedAt int64
        err := database.QueryRow(
            "SELECT updated_at FROM records WHERE id=?", rec.ID,
        ).Scan(&existingUpdatedAt)
        if err == nil && existingUpdatedAt >= rec.UpdatedAt {
            w.Header().Set("Content-Type", "application/json")
            w.WriteHeader(http.StatusOK)
            json.NewEncoder(w).Encode(rec)
            return
        }

        _, err = database.Exec(`
            INSERT OR REPLACE INTO records
            (id, schema, lang_code, payload, created_at, updated_at, device_id, hop_count)
            VALUES (?,?,?,?,?,?,?,?)`,
            rec.ID, rec.Schema, rec.LangCode, rec.Payload,
            rec.CreatedAt, rec.UpdatedAt, rec.DeviceID, rec.HopCount,
        )
        if err != nil {
            http.Error(w, `{"error":"db error"}`, 500)
            return
        }
        w.Header().Set("Content-Type", "application/json")
        w.WriteHeader(http.StatusCreated)
        json.NewEncoder(w).Encode(rec)
    }
}

func listRecords(database *db.DB) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        schema := r.URL.Query().Get("schema")
        var rows *sql.Rows
        var err error
        if schema != "" {
            rows, err = database.Query(
                "SELECT id,schema,lang_code,payload,created_at,updated_at,device_id,hop_count FROM records WHERE schema=? ORDER BY updated_at DESC", schema)
        } else {
            rows, err = database.Query(
                "SELECT id,schema,lang_code,payload,created_at,updated_at,device_id,hop_count FROM records ORDER BY updated_at DESC")
        }
        if err != nil {
            http.Error(w, `{"error":"db error"}`, 500)
            return
        }
        defer rows.Close()
        var records []Record
        for rows.Next() {
            var rec Record
            rows.Scan(&rec.ID, &rec.Schema, &rec.LangCode, &rec.Payload,
                &rec.CreatedAt, &rec.UpdatedAt, &rec.DeviceID, &rec.HopCount)
            records = append(records, rec)
        }
        if records == nil { records = []Record{} }
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(records)
    }
}

func getRecord(database *db.DB) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        id := mux.Vars(r)["id"]
        var rec Record
        err := database.QueryRow(
            "SELECT id,schema,lang_code,payload,created_at,updated_at,device_id,hop_count FROM records WHERE id=?", id,
        ).Scan(&rec.ID, &rec.Schema, &rec.LangCode, &rec.Payload,
            &rec.CreatedAt, &rec.UpdatedAt, &rec.DeviceID, &rec.HopCount)
        if err == sql.ErrNoRows {
            http.Error(w, `{"error":"not found"}`, 404)
            return
        }
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(rec)
    }
}

func pullBatch(database *db.DB) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        var since int64
        json.Unmarshal([]byte(r.URL.Query().Get("since")), &since)
        rows, err := database.Query(
            "SELECT id,schema,lang_code,payload,created_at,updated_at,device_id,hop_count FROM records WHERE updated_at > ? ORDER BY updated_at ASC", since)
        if err != nil {
            http.Error(w, `{"error":"db error"}`, 500)
            return
        }
        defer rows.Close()
        var records []Record
        for rows.Next() {
            var rec Record
            rows.Scan(&rec.ID, &rec.Schema, &rec.LangCode, &rec.Payload,
                &rec.CreatedAt, &rec.UpdatedAt, &rec.DeviceID, &rec.HopCount)
            records = append(records, rec)
        }
        if records == nil { records = []Record{} }
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(map[string]interface{}{
            "new_records": records,
            "server_ts":   time.Now().UnixMilli(),
        })
    }
}

func pushBatch(database *db.DB) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        var batch struct {
            Records []Record `json:"records"`
        }
        if err := json.NewDecoder(r.Body).Decode(&batch); err != nil {
            http.Error(w, `{"error":"invalid JSON"}`, 400)
            return
        }
        synced := 0
        for _, rec := range batch.Records {
            var existingTs int64
            database.QueryRow("SELECT updated_at FROM records WHERE id=?", rec.ID).Scan(&existingTs)
            if existingTs >= rec.UpdatedAt { continue }
            database.Exec(`INSERT OR REPLACE INTO records
                (id,schema,lang_code,payload,created_at,updated_at,device_id,hop_count)
                VALUES (?,?,?,?,?,?,?,?)`,
                rec.ID, rec.Schema, rec.LangCode, rec.Payload,
                rec.CreatedAt, rec.UpdatedAt, rec.DeviceID, rec.HopCount)
            synced++
        }
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(map[string]int{"synced": synced})
    }
}
