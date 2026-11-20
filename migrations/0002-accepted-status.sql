CREATE TEMP TABLE saved_items AS SELECT * FROM items;
CREATE TEMP TABLE saved_deps AS SELECT * FROM deps;
CREATE TEMP TABLE saved_item_paths AS SELECT * FROM item_paths;
CREATE TEMP TABLE saved_events AS SELECT * FROM events;

DROP TABLE events;
DROP TABLE item_paths;
DROP TABLE deps;
DROP TABLE items;

CREATE TABLE items (
  id TEXT PRIMARY KEY,
  roadmap_id TEXT NOT NULL REFERENCES roadmaps (id),
  parent_id TEXT REFERENCES items (id),
  title TEXT NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('epic', 'research', 'design', 'build')),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'dispatched', 'reported', 'in_review', 'fixing', 'merging', 'merged', 'accepted', 'dropped')),
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

INSERT INTO items (id, roadmap_id, parent_id, title, kind, status, origin, priority, claimed_by, created_at, closed_at)
  SELECT id, roadmap_id, parent_id, title, kind, status, origin, priority, claimed_by, created_at, closed_at FROM saved_items;
INSERT INTO deps (item_id, on_id, type) SELECT item_id, on_id, type FROM saved_deps;
INSERT INTO item_paths (item_id, glob) SELECT item_id, glob FROM saved_item_paths;
INSERT INTO events (id, at, actor, roadmap_id, item_id, type, payload_json)
  SELECT id, at, actor, roadmap_id, item_id, type, payload_json FROM saved_events;

DROP TABLE saved_items;
DROP TABLE saved_deps;
DROP TABLE saved_item_paths;
DROP TABLE saved_events;
