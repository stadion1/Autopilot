-- ============================================================
-- Bilanalys — Supabase schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ─── Core analysis table ─────────────────────────────────────────────────────

CREATE TABLE analyses (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at  TIMESTAMPTZ DEFAULT now(),

  -- Input
  source_url  TEXT NOT NULL,
  source_site TEXT NOT NULL CHECK (source_site IN ('blocket','wayke','bytbil')),
  status      TEXT NOT NULL DEFAULT 'pending'
              CHECK (status IN ('pending','processing','done','error')),
  error       TEXT,

  -- Scraped car data
  brand           TEXT,
  model           TEXT,
  variant         TEXT,
  year            INT,
  price_sek       INT,
  mileage_km      INT,
  fuel_type       TEXT,
  transmission    TEXT,
  horsepower      INT,
  color           TEXT,
  location        TEXT,
  description     TEXT,
  images          TEXT[],
  seller_type     TEXT CHECK (seller_type IN ('private','dealer')),
  raw_html        TEXT,     -- stored for re-parsing (avoids re-scraping)

  -- Scores (0–100)
  deal_score           INT CHECK (deal_score BETWEEN 0 AND 100),
  price_score          INT CHECK (price_score BETWEEN 0 AND 100),
  reliability_score    INT CHECK (reliability_score BETWEEN 0 AND 100),
  ownership_score      INT CHECK (ownership_score BETWEEN 0 AND 100),
  mileage_score        INT CHECK (mileage_score BETWEEN 0 AND 100),
  resale_score         INT CHECK (resale_score BETWEEN 0 AND 100),

  -- Confidence
  confidence_score    INT,
  confidence_tier     TEXT CHECK (confidence_tier IN ('high','medium','low')),
  confidence_reasons  TEXT[],

  -- Pricing
  fair_price_low      INT,
  fair_price_median   INT,
  fair_price_high     INT,
  price_delta_pct     NUMERIC(6,3),

  -- AI analysis output
  pros        TEXT[],
  cons        TEXT[],
  risks       JSONB,        -- [{level, title, description, rule_id}]
  verdict     TEXT CHECK (verdict IN ('Bra affär','Okej affär','Tveksam affär')),
  ai_summary  TEXT,

  -- Meta / versioning
  scoring_version   TEXT DEFAULT '1.0.0',
  data_sources      TEXT[]
);

-- Indexes
CREATE INDEX ON analyses (source_url);
CREATE INDEX ON analyses (status);
CREATE INDEX ON analyses (created_at DESC);
CREATE INDEX ON analyses (brand, model, year);


-- ─── Model reference data ────────────────────────────────────────────────────

CREATE TABLE model_references (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand           TEXT NOT NULL,
  model           TEXT NOT NULL,
  variant_pattern TEXT,         -- NULL = applies to all variants; regex match
  year_from       INT NOT NULL,
  year_to         INT NOT NULL,

  -- Pricing
  base_price_sek          INT NOT NULL,   -- New car list price (SEK)
  depreciation_rate       NUMERIC(5,4) DEFAULT 0.1200,  -- Annual rate, e.g. 0.12
  avg_mil_per_year        INT DEFAULT 1500,
  price_per_1000_extra_mil INT DEFAULT -2500,  -- SEK per 1000 mil above expected

  -- Scoring bases (0–100)
  reliability_base  INT DEFAULT 70,
  resale_base       INT DEFAULT 65,

  -- Metadata
  notes      TEXT,
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE UNIQUE INDEX ON model_references (brand, model, year_from, year_to)
  WHERE variant_pattern IS NULL;

-- Seed data: top 15 models on Swedish market
INSERT INTO model_references (brand, model, year_from, year_to, base_price_sek, depreciation_rate, reliability_base, resale_base) VALUES
  ('Volvo',       'V60',       2018, 2024, 420000, 0.130, 75, 72),
  ('Volvo',       'XC60',      2018, 2024, 520000, 0.125, 74, 74),
  ('Volvo',       'V90',       2018, 2024, 560000, 0.130, 74, 71),
  ('Volvo',       'XC40',      2018, 2024, 390000, 0.135, 72, 70),
  ('Toyota',      'Corolla',   2018, 2024, 310000, 0.110, 88, 70),
  ('Toyota',      'RAV4',      2018, 2024, 420000, 0.115, 86, 72),
  ('Toyota',      'Yaris',     2018, 2024, 240000, 0.110, 87, 68),
  ('Volkswagen',  'Golf',      2018, 2024, 310000, 0.115, 72, 65),
  ('Volkswagen',  'Tiguan',    2018, 2024, 410000, 0.120, 70, 67),
  ('BMW',         '3-serie',   2018, 2024, 480000, 0.145, 60, 68),
  ('BMW',         '5-serie',   2018, 2024, 680000, 0.150, 58, 66),
  ('Mercedes-Benz','C-klass',  2018, 2024, 520000, 0.145, 62, 67),
  ('Skoda',       'Octavia',   2018, 2024, 320000, 0.120, 74, 66),
  ('Hyundai',     'Tucson',    2018, 2024, 380000, 0.125, 76, 67),
  ('Kia',         'Sportage',  2018, 2024, 370000, 0.120, 77, 68);


-- ─── Known issues and recalls ────────────────────────────────────────────────

CREATE TABLE known_issues (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand        TEXT NOT NULL,
  model        TEXT,       -- NULL = applies to all models from this brand
  year_from    INT,
  year_to      INT,
  fuel_type    TEXT,       -- NULL = all fuel types

  severity     TEXT NOT NULL CHECK (severity IN ('high','medium','low')),
  category     TEXT CHECK (category IN ('engine','gearbox','electrical','recall','rust','other')),
  rule_id      TEXT UNIQUE,   -- e.g. 'volvo_v60_2020_brake_recall'
  title        TEXT NOT NULL,
  description  TEXT NOT NULL,
  source_url   TEXT,

  created_at   TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX ON known_issues (brand, model);
CREATE INDEX ON known_issues (rule_id);

-- Seed with some real examples
INSERT INTO known_issues (brand, model, year_from, year_to, severity, category, rule_id, title, description) VALUES
  ('Volvo', 'V60',  2020, 2021, 'low',    'recall',     'volvo_v60_2020_brakes',
   'Återkallelse: bromsmjukvara',
   'Volvo återkallade V60 2020–2021 för en uppdatering av ABS-systemets mjukvara. Kontrollera med Volvos återförsäljare att åtgärden är utförd.'),

  ('BMW',   '3-serie', 2012, 2018, 'medium', 'engine',  'bmw_3_n20_timing_chain',
   'N20/N26 motor: timing chain-slitage',
   'BMW:s N20 och N26 fyrcylindriga motorer (2012–2018) kan drabbas av för tidigt timing chain-slitage. Kontrollera servicehistorik noggrant och lyssna efter skrammel vid kallstart.'),

  ('Volkswagen', 'Golf', 2013, 2016, 'medium', 'gearbox', 'vw_golf_dsg7_tcm',
   'DSG7 (DQ200) växellåda: ryckningar',
   'Vissa VW Golf med 7-stegs DSG-låda (DQ200) har rapporterats ge ryckningar vid låga hastigheter. En mjukvaruuppdatering finns tillgänglig via auktoriserad VW-verkstad.'),

  ('Volvo', 'XC60', 2018, 2020, 'low', 'electrical', 'volvo_xc60_sensus_infotainment',
   'Sensus infotainment: uppfrysningar',
   'Volvo XC60 2018–2020 kan uppleva att Sensus infotainment-systemet fryser eller startar om spontant. Lösning: mjukvaruuppdatering via Volvos återförsäljare.');


-- ─── Market listings (populated by nightly scraper in Phase 2) ───────────────

CREATE TABLE market_listings (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scraped_at   TIMESTAMPTZ DEFAULT now(),

  source_url   TEXT,
  source_site  TEXT,
  brand        TEXT,
  model        TEXT,
  variant      TEXT,
  year         INT,
  price_sek    INT,
  mileage_km   INT,
  fuel_type    TEXT,
  transmission TEXT,
  location     TEXT,
  seller_type  TEXT,

  sold_at      TIMESTAMPTZ,    -- set when listing disappears (proxy for sold)
  days_listed  INT             -- calculated on removal
);

CREATE INDEX ON market_listings (brand, model, year);
CREATE INDEX ON market_listings (scraped_at DESC);
CREATE INDEX ON market_listings (sold_at) WHERE sold_at IS NOT NULL;


-- ─── User feedback ────────────────────────────────────────────────────────────

CREATE TABLE analysis_feedback (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  analysis_id  UUID REFERENCES analyses(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ DEFAULT now(),

  was_accurate        BOOLEAN,
  actual_sale_price   INT,
  feedback_type       TEXT CHECK (feedback_type IN ('too_high','too_low','wrong_risk','helpful','inaccurate')),
  notes               TEXT,

  -- Implicit engagement signals
  time_on_page_sec    INT,
  shared              BOOLEAN DEFAULT false,
  returned_30d        BOOLEAN DEFAULT false
);

CREATE INDEX ON analysis_feedback (analysis_id);


-- ─── Helper function for market median ───────────────────────────────────────

CREATE OR REPLACE FUNCTION get_market_median(
  p_brand TEXT,
  p_model TEXT,
  p_year  INT
)
RETURNS TABLE (median NUMERIC, sample_size BIGINT)
LANGUAGE SQL STABLE AS $$
  SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_sek)::NUMERIC AS median,
    COUNT(*) AS sample_size
  FROM market_listings
  WHERE
    LOWER(brand) = LOWER(p_brand)
    AND LOWER(model) = LOWER(p_model)
    AND year = p_year
    AND scraped_at > NOW() - INTERVAL '90 days'
    AND sold_at IS NULL
    AND price_sek > 0;
$$;


-- ─── Row Level Security ───────────────────────────────────────────────────────
-- analyses are publicly readable (no auth in MVP) but only insertable via service role

ALTER TABLE analyses         ENABLE ROW LEVEL SECURITY;
ALTER TABLE analysis_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE market_listings   ENABLE ROW LEVEL SECURITY;

-- Public can read completed analyses
CREATE POLICY "Public read done analyses"
  ON analyses FOR SELECT
  USING (status = 'done');

-- Service role (used by API) can do everything
-- (service role bypasses RLS by default in Supabase)


-- ============================================================
-- Migration: nightly scraper support (NIGHTLY_SCRAPER.md)
-- Run this once in Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Needed for upsert-on-conflict dedup in scraper-service/nightly.ts
ALTER TABLE market_listings ADD COLUMN IF NOT EXISTS first_seen_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE market_listings ADD CONSTRAINT market_listings_source_url_key UNIQUE (source_url);

-- Marks listings not re-seen in p_grace_days nights as sold. A single missed
-- night isn't strong evidence of a sale — the nightly job only samples a
-- rotating subset of the total market, so a grace period avoids false positives.
CREATE OR REPLACE FUNCTION mark_stale_listings_sold(p_grace_days INT DEFAULT 5)
RETURNS INT
LANGUAGE SQL AS $$
  WITH updated AS (
    UPDATE market_listings
    SET sold_at     = now(),
        days_listed = GREATEST(1, EXTRACT(DAY FROM now() - first_seen_at))::INT
    WHERE sold_at IS NULL
      AND scraped_at < now() - (p_grace_days::TEXT || ' days')::INTERVAL
    RETURNING 1
  )
  SELECT COUNT(*)::INT FROM updated;
$$;
