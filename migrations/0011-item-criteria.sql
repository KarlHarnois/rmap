CREATE TABLE item_criteria (
  item_id TEXT NOT NULL REFERENCES items (id),
  position INTEGER NOT NULL,
  text TEXT NOT NULL,
  PRIMARY KEY (item_id, position)
);
