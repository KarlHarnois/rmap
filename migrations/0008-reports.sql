CREATE TABLE reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_id TEXT REFERENCES items (id),
  session_id INTEGER REFERENCES sessions (id),
  kind TEXT CHECK (kind IN ('done', 'fixed', 'question')),
  body TEXT NOT NULL,
  created_at TEXT NOT NULL,
  read_at TEXT
);

CREATE INDEX reports_item ON reports (item_id);
