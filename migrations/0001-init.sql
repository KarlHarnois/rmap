CREATE TABLE roadmaps (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  manager_session TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'done')),
  created_at TEXT NOT NULL
);

CREATE TABLE items (
  id TEXT PRIMARY KEY,
  roadmap_id TEXT NOT NULL REFERENCES roadmaps (id),
  parent_id TEXT REFERENCES items (id),
  title TEXT NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('epic', 'research', 'design', 'build')),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'dispatched', 'reported', 'in_review', 'fixing', 'merging', 'merged', 'dropped')),
  origin TEXT NOT NULL DEFAULT 'planned' CHECK (origin IN ('planned', 'user-bug', 'follow-up')),
  priority INTEGER NOT NULL DEFAULT 0,
  claimed_by TEXT,
  created_at TEXT NOT NULL,
  closed_at TEXT
);

CREATE INDEX items_roadmap ON items (roadmap_id);

CREATE TABLE deps (
  item_id TEXT NOT NULL REFERENCES items (id),
  on_id TEXT NOT NULL REFERENCES items (id),
  type TEXT NOT NULL CHECK (type IN ('blocks', 'discovered_from')),
  PRIMARY KEY (item_id, on_id, type)
);

CREATE TABLE item_paths (
  item_id TEXT NOT NULL REFERENCES items (id),
  glob TEXT NOT NULL,
  PRIMARY KEY (item_id, glob)
);

CREATE TABLE events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  at TEXT NOT NULL,
  actor TEXT NOT NULL,
  roadmap_id TEXT REFERENCES roadmaps (id),
  item_id TEXT REFERENCES items (id),
  type TEXT NOT NULL,
  payload_json TEXT NOT NULL
);

CREATE INDEX events_item ON events (item_id);
