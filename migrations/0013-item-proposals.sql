CREATE TABLE item_proposals (
  source_item_id TEXT NOT NULL REFERENCES items (id),
  proposal_id TEXT NOT NULL,
  position INTEGER NOT NULL,
  title TEXT NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('epic', 'research', 'design', 'build')),
  priority INTEGER NOT NULL,
  description TEXT NOT NULL,
  decision_id TEXT REFERENCES decisions (id),
  decision_option INTEGER,
  created_item_id TEXT REFERENCES items (id),
  PRIMARY KEY (source_item_id, proposal_id),
  CHECK ((decision_id IS NULL) = (decision_option IS NULL))
);

CREATE TABLE item_proposal_criteria (
  source_item_id TEXT NOT NULL,
  proposal_id TEXT NOT NULL,
  position INTEGER NOT NULL,
  text TEXT NOT NULL,
  PRIMARY KEY (source_item_id, proposal_id, position),
  FOREIGN KEY (source_item_id, proposal_id) REFERENCES item_proposals (source_item_id, proposal_id)
);

CREATE TABLE item_proposal_deps (
  source_item_id TEXT NOT NULL,
  proposal_id TEXT NOT NULL,
  position INTEGER NOT NULL,
  on_id TEXT NOT NULL,
  PRIMARY KEY (source_item_id, proposal_id, position),
  FOREIGN KEY (source_item_id, proposal_id) REFERENCES item_proposals (source_item_id, proposal_id)
);

CREATE TABLE decision_option_skips (
  decision_id TEXT NOT NULL,
  option_number INTEGER NOT NULL,
  position INTEGER NOT NULL,
  proposal_id TEXT NOT NULL,
  PRIMARY KEY (decision_id, option_number, position),
  FOREIGN KEY (decision_id, option_number) REFERENCES decision_options (decision_id, number)
);
