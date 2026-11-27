ALTER TABLE items ADD COLUMN exclusive TEXT NOT NULL DEFAULT 'not-exclusive'
  CHECK (exclusive IN ('not-exclusive', 'exclusive'));
