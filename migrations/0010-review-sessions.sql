CREATE TEMP TABLE saved_sessions AS SELECT * FROM sessions;
CREATE TEMP TABLE saved_reports AS SELECT * FROM reports;
CREATE TEMP TABLE saved_reviews AS SELECT * FROM reviews;

DROP TABLE reviews;
DROP TABLE reports;
DROP TABLE sessions;

CREATE TABLE sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  item_id TEXT REFERENCES items (id),
  kind TEXT CHECK (kind IN ('work', 'fix', 'review')),
  runtime TEXT NOT NULL DEFAULT 'ringleader',
  branch TEXT,
  base TEXT,
  started_at TEXT NOT NULL,
  ended_at TEXT,
  end_reason TEXT CHECK (end_reason IN ('reopened', 'replaced', 'finished', 'superseded'))
);

CREATE UNIQUE INDEX sessions_live_name ON sessions (name) WHERE ended_at IS NULL;

CREATE UNIQUE INDEX sessions_live_work_item ON sessions (item_id) WHERE ended_at IS NULL AND kind IN ('work', 'fix');

CREATE UNIQUE INDEX sessions_live_review_item ON sessions (item_id) WHERE ended_at IS NULL AND kind = 'review';

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

CREATE TABLE reviews (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_id TEXT NOT NULL REFERENCES pull_requests (item_id),
  session_id INTEGER NOT NULL REFERENCES sessions (id),
  kind TEXT NOT NULL CHECK (kind IN ('behavior', 'design')),
  head_sha TEXT NOT NULL,
  verdict TEXT NOT NULL CHECK (verdict IN ('changes', 'approve')),
  created_at TEXT NOT NULL
);

CREATE INDEX reviews_item ON reviews (item_id);

INSERT INTO sessions (id, name, item_id, kind, runtime, branch, base, started_at, ended_at, end_reason)
  SELECT id, name, item_id, kind, runtime, branch, base, started_at, ended_at, end_reason FROM saved_sessions;
INSERT INTO reports (id, item_id, session_id, kind, body, created_at, read_at)
  SELECT id, item_id, session_id, kind, body, created_at, read_at FROM saved_reports;
INSERT INTO reviews (id, item_id, session_id, kind, head_sha, verdict, created_at)
  SELECT id, item_id, session_id, kind, head_sha, verdict, created_at FROM saved_reviews;

DROP TABLE saved_sessions;
DROP TABLE saved_reports;
DROP TABLE saved_reviews;

UPDATE sessions
SET kind = 'review',
    started_at = (SELECT created_at FROM reviews WHERE reviews.session_id = sessions.id),
    ended_at = (SELECT created_at FROM reviews WHERE reviews.session_id = sessions.id),
    end_reason = 'finished'
WHERE id IN (SELECT session_id FROM reviews);
