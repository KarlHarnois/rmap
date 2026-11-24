CREATE TABLE sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  item_id TEXT REFERENCES items (id),
  kind TEXT CHECK (kind IN ('work', 'fix')),
  runtime TEXT NOT NULL DEFAULT 'ringleader',
  branch TEXT,
  base TEXT,
  started_at TEXT NOT NULL,
  ended_at TEXT,
  end_reason TEXT CHECK (end_reason IN ('reopened', 'replaced', 'finished'))
);

CREATE UNIQUE INDEX sessions_live_item ON sessions (item_id) WHERE ended_at IS NULL;

CREATE UNIQUE INDEX sessions_live_name ON sessions (name) WHERE ended_at IS NULL;

WITH claims AS (
  SELECT items.id AS item_id,
         items.claimed_by AS name,
         items.status IN ('merged', 'accepted', 'dropped') AS finished,
         items.closed_at AS closed_at,
         COALESCE((SELECT MAX(events.at) FROM events WHERE events.item_id = items.id AND events.type = 'item-claimed'), items.created_at) AS started_at
  FROM items
  WHERE items.claimed_by IS NOT NULL
),
ranked AS (
  SELECT claims.*,
         ROW_NUMBER() OVER (PARTITION BY name, finished ORDER BY started_at DESC, item_id DESC) AS recency,
         MAX(started_at) OVER (PARTITION BY name, finished) AS newest_start
  FROM claims
)
INSERT INTO sessions (name, item_id, kind, branch, base, started_at, ended_at, end_reason)
  SELECT name, item_id, 'work', NULL, NULL, started_at,
         CASE WHEN finished THEN COALESCE(closed_at, started_at) WHEN recency > 1 THEN newest_start END,
         CASE WHEN finished THEN 'finished' WHEN recency > 1 THEN 'replaced' END
  FROM ranked
  ORDER BY started_at, item_id;

ALTER TABLE items DROP COLUMN claimed_by;
