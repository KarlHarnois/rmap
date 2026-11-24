CREATE TABLE decisions (
  id TEXT PRIMARY KEY,
  roadmap_id TEXT NOT NULL REFERENCES roadmaps (id),
  item_id TEXT REFERENCES items (id),
  title TEXT NOT NULL,
  context TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'proposed' CHECK (status IN ('proposed', 'accepted', 'rejected', 'deprecated', 'superseded')),
  recommended_option INTEGER NOT NULL,
  recommendation_reason TEXT NOT NULL,
  chosen_option INTEGER,
  justification TEXT,
  consequences TEXT,
  deprecation_reason TEXT,
  supersedes_id TEXT REFERENCES decisions (id),
  asked_at TEXT,
  decided_by TEXT,
  decided_at TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (id, recommended_option) REFERENCES decision_options (decision_id, number) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (id, chosen_option) REFERENCES decision_options (decision_id, number) DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX decisions_roadmap ON decisions (roadmap_id);

CREATE TABLE decision_options (
  decision_id TEXT NOT NULL REFERENCES decisions (id),
  number INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (decision_id, number)
);

CREATE TABLE decision_option_points (
  decision_id TEXT NOT NULL,
  option_number INTEGER NOT NULL,
  side TEXT NOT NULL CHECK (side IN ('pro', 'con')),
  position INTEGER NOT NULL,
  text TEXT NOT NULL,
  PRIMARY KEY (decision_id, option_number, side, position),
  FOREIGN KEY (decision_id, option_number) REFERENCES decision_options (decision_id, number)
);

CREATE TABLE decision_blocks (
  decision_id TEXT NOT NULL REFERENCES decisions (id),
  item_id TEXT NOT NULL REFERENCES items (id),
  PRIMARY KEY (decision_id, item_id)
);

CREATE INDEX decision_blocks_item ON decision_blocks (item_id);

CREATE TABLE rulings (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL REFERENCES items (id),
  question TEXT NOT NULL,
  choice TEXT NOT NULL,
  reason TEXT NOT NULL,
  supersedes_id TEXT UNIQUE REFERENCES rulings (id),
  ruled_by TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE INDEX rulings_item ON rulings (item_id);

ALTER TABLE events ADD COLUMN decision_id TEXT REFERENCES decisions (id);

CREATE INDEX events_decision ON events (decision_id);
