CREATE TABLE external_blockers (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL REFERENCES items (id),
  text TEXT NOT NULL CHECK (length(trim(text)) > 0),
  created_at TEXT NOT NULL,
  created_by TEXT NOT NULL,
  cleared_at TEXT,
  cleared_by TEXT,
  clear_note TEXT
);

CREATE INDEX external_blockers_item ON external_blockers (item_id);
