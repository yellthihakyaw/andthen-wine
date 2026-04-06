-- ============================================================
-- &THEN Wine List — Supabase Database Setup
-- Run this entire file in your Supabase SQL Editor
-- ============================================================

-- 1. Create the wines table
CREATE TABLE IF NOT EXISTS wines (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name       text NOT NULL,
  category   text NOT NULL,
  price      integer NOT NULL DEFAULT 0,
  quantity   integer NOT NULL DEFAULT 0,
  region     text,
  country    text,
  notes      text,
  grape      text,
  photo_url  text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- 2. Auto-update the updated_at column on every edit
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at ON wines;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON wines
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 3. Enable Row Level Security
ALTER TABLE wines ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies
--    Public visitors can READ wines (for the menu page)
CREATE POLICY "Public read wines"
  ON wines FOR SELECT
  USING (true);

--    Anon key can also INSERT / UPDATE / DELETE
--    (Your admin password gate is client-side, so the anon key
--     handles writes — keep your ANON KEY private in Vercel env vars)
CREATE POLICY "Anon insert wines"
  ON wines FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anon update wines"
  ON wines FOR UPDATE
  USING (true);

CREATE POLICY "Anon delete wines"
  ON wines FOR DELETE
  USING (true);

-- 5. Enable Realtime for live updates
ALTER PUBLICATION supabase_realtime ADD TABLE wines;

-- ============================================================
-- Done! Your wines table is ready.
-- ============================================================
