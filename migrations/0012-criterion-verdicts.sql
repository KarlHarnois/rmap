CREATE TABLE criterion_verdicts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_id TEXT NOT NULL REFERENCES items (id),
  position INTEGER NOT NULL,
  verdict TEXT NOT NULL CHECK (verdict IN ('met', 'failed')),
  note TEXT,
  reviewer_session_id INTEGER NOT NULL REFERENCES sessions (id),
  head TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (item_id, position) REFERENCES item_criteria (item_id, position)
);

CREATE INDEX criterion_verdicts_item ON criterion_verdicts (item_id);
