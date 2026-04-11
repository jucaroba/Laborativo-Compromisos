-- ═══════════════════════════════════════════════════════════
-- MIGRACIÓN: Módulo de administración multi-sesión
-- Corre esto en el SQL Editor de Supabase ANTES de hacer deploy
-- ═══════════════════════════════════════════════════════════

-- 1. Tabla de sesiones
CREATE TABLE IF NOT EXISTS sessions (
  id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name     TEXT NOT NULL,
  question TEXT NOT NULL DEFAULT '¿A qué te comprometes para ganar como equipo?',
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sessions_all" ON sessions FOR ALL USING (true) WITH CHECK (true);

-- 2. Tabla de categorías por sesión
CREATE TABLE IF NOT EXISTS session_categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id  UUID REFERENCES sessions(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  order_index INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE session_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "session_categories_all" ON session_categories FOR ALL USING (true) WITH CHECK (true);

-- 3. Agregar session_id a commitments
ALTER TABLE commitments ADD COLUMN IF NOT EXISTS session_id UUID REFERENCES sessions(id) ON DELETE CASCADE;

-- 4. Cambiar category_id a UUID para usar los IDs de session_categories
--    (esto pone NULL en registros viejos, que ya no se mostrarán en ninguna sesión)
ALTER TABLE commitments ALTER COLUMN category_id TYPE UUID USING NULL;

-- 5. Índices
CREATE INDEX IF NOT EXISTS idx_commitments_session_id ON commitments(session_id);
CREATE INDEX IF NOT EXISTS idx_session_categories_session_id ON session_categories(session_id);
