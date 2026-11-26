ALTER TABLE roadmaps ADD COLUMN max_active INTEGER
  CHECK (max_active IS NULL OR max_active >= 1);
