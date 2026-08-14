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
  -- 'new_car_list' when fair_price_median is Skatteverket's new-car list
  -- price (essentially-new cars, see isEssentiallyNewCar in engine.ts)
  -- rather than a real market median — UI labels it differently.
  -- 'theoretical' = neither available, basePrice x (1-depreciation)^age
  -- formula guess from referenceData.ts (see migration below).
  median_source       TEXT CHECK (median_source IN ('market','new_car_list','theoretical')) DEFAULT 'market',

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
-- SUPERSEDED 2026-08-12 by the MAD-robust version further down in this file
-- (same function name, CREATE OR REPLACE — kept here only as a historical
-- record of the original, simpler version).

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

-- SUPERSEDED as of the "sold-verifiering" change in scraper-service/nightly.ts
-- (verifyAndMarkSoldListings) — kept here for reference/rollback only, no
-- longer called. Marking "not re-seen in N nights" as sold turned out to
-- produce real false positives: the rotating relevance-sorted sample only
-- covers a small slice of the market per night, so a still-active listing
-- can plausibly miss the sample for 5+ consecutive nights on sort-order
-- noise alone. nightly.ts now verifies each stale candidate against
-- Blocket's own ad-detail endpoint before marking it sold.
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


-- ============================================================
-- Migration: registration number + VIN
-- Run this once in Supabase Dashboard → SQL Editor → New Query
-- ============================================================
-- blocket-api.se's specifications already include these as plain text
-- (Registreringsnummer/Chassinummer) — no OCR needed, just wasn't extracted.

ALTER TABLE analyses ADD COLUMN IF NOT EXISTS registration_number TEXT;
ALTER TABLE analyses ADD COLUMN IF NOT EXISTS vin TEXT;


-- ============================================================
-- Migration: registration_date + market_listings VIN dedup
-- Run this once in Supabase Dashboard → SQL Editor → New Query
-- ============================================================
-- registration_date gives scoring an exact vehicle age instead of the
-- coarse (current_year - model_year), which undercounts age for cars
-- first registered mid-way through the previous calendar year.

ALTER TABLE analyses ADD COLUMN IF NOT EXISTS registration_date DATE;

-- The same physical car can be listed on both Blocket and Wayke at once.
-- Both write to market_listings keyed by source_url, which differs per
-- site, so without this the same car would be double-counted in
-- get_market_median(). VIN is the strongest cross-site identifier, but
-- the nightly scraper's search endpoint only exposes registration_number
-- (no VIN) — so the dedup checks both.
ALTER TABLE market_listings ADD COLUMN IF NOT EXISTS vin TEXT;
ALTER TABLE market_listings ADD COLUMN IF NOT EXISTS registration_number TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS market_listings_vin_key
  ON market_listings (vin) WHERE vin IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS market_listings_regnr_key
  ON market_listings (registration_number) WHERE registration_number IS NOT NULL;

-- Upserts on VIN or registration_number when known (regardless of
-- source_url — catches the same car cross-listed on another site),
-- falling back to the existing source_url-based upsert otherwise.
CREATE OR REPLACE FUNCTION upsert_market_listing(
  p_source_url  TEXT, p_source_site TEXT, p_brand TEXT, p_model TEXT,
  p_variant     TEXT, p_year INT, p_price_sek INT, p_mileage_km INT,
  p_fuel_type   TEXT, p_transmission TEXT, p_location TEXT,
  p_seller_type TEXT, p_vin TEXT, p_registration_number TEXT
) RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE
  v_existing_id UUID;
BEGIN
  SELECT id INTO v_existing_id FROM market_listings
  WHERE (p_vin IS NOT NULL AND vin = p_vin)
     OR (p_registration_number IS NOT NULL AND registration_number = p_registration_number)
  LIMIT 1;

  IF v_existing_id IS NOT NULL THEN
    UPDATE market_listings SET
      source_url = p_source_url, source_site = p_source_site,
      brand = p_brand, model = p_model, variant = p_variant, year = p_year,
      price_sek = p_price_sek, mileage_km = p_mileage_km, fuel_type = p_fuel_type,
      transmission = p_transmission, location = p_location, seller_type = p_seller_type,
      vin = COALESCE(p_vin, vin),
      registration_number = COALESCE(p_registration_number, registration_number),
      scraped_at = now(), sold_at = NULL
    WHERE id = v_existing_id;
  ELSE
    INSERT INTO market_listings (
      source_url, source_site, brand, model, variant, year, price_sek, mileage_km,
      fuel_type, transmission, location, seller_type, vin, registration_number,
      scraped_at, sold_at
    ) VALUES (
      p_source_url, p_source_site, p_brand, p_model, p_variant, p_year, p_price_sek, p_mileage_km,
      p_fuel_type, p_transmission, p_location, p_seller_type, p_vin, p_registration_number,
      now(), NULL
    )
    ON CONFLICT (source_url) DO UPDATE SET
      brand = EXCLUDED.brand, model = EXCLUDED.model, variant = EXCLUDED.variant, year = EXCLUDED.year,
      price_sek = EXCLUDED.price_sek, mileage_km = EXCLUDED.mileage_km, fuel_type = EXCLUDED.fuel_type,
      transmission = EXCLUDED.transmission, location = EXCLUDED.location, seller_type = EXCLUDED.seller_type,
      vin = EXCLUDED.vin, registration_number = EXCLUDED.registration_number,
      scraped_at = now(), sold_at = NULL;
  END IF;
END;
$$;


-- ============================================================
-- Migration: deal_score for market_listings
-- Run this once in Supabase Dashboard → SQL Editor → New Query
-- ============================================================
-- Lets "find a better deal" queries sort by a stored deal_score instead of
-- scoring every candidate live on each request. Populated and kept fresh by
-- a separate Vercel Cron job (pages/api/cron/score-listings.ts) that reuses
-- the same scoring engine as a single-car analysis — NOT by the nightly
-- scraper itself, since lib/scoring/engine.ts lives in the main app and
-- scraper-service (Railway) is built/deployed independently of it.
--
-- Needs periodic re-scoring, not just a one-time value at insert time:
-- get_market_median() is computed live from market_listings, so a score
-- computed when only 2 rows exist for a brand/model becomes stale once 50
-- more accumulate. deal_score_updated_at drives that re-scoring cadence.

ALTER TABLE market_listings ADD COLUMN IF NOT EXISTS deal_score INT;
ALTER TABLE market_listings ADD COLUMN IF NOT EXISTS deal_score_updated_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS market_listings_deal_score_idx
  ON market_listings (brand, model, deal_score DESC)
  WHERE sold_at IS NULL;


-- ============================================================
-- Migration: new_car_prices (Skatteverket nybilspriser)
-- Run this once in Supabase Dashboard → SQL Editor → New Query
-- ============================================================
-- Real trim-level new-car list prices from Skatteverket's open data API
-- (CC0, https://skatteverket.entryscape.net/rowstore/dataset/fad86bf9-
-- 67e3-4d68-829c-7b9a23bc5e42), synced periodically by
-- pages/api/cron/sync-new-car-prices.ts. Used as the reference price for
-- essentially-new cars (near-zero mileage) instead of the flat per-model
-- basePrice in data/referenceData.ts, which can't capture that e.g. a
-- Volvo XC60 spans 560 000–893 000 kr new depending on trim.

CREATE TABLE new_car_prices (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_code        TEXT UNIQUE NOT NULL,  -- Skatteverkets "kod" — stabil per rad/trim/år
  brand              TEXT NOT NULL,
  model_raw          TEXT NOT NULL,         -- t.ex. "XC60 T6 Plus Nordic Edition"
  manufacturing_year INT NOT NULL,
  price_sek          INT NOT NULL,
  fuel_type          TEXT,
  synced_at          TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX ON new_car_prices (brand, manufacturing_year);

ALTER TABLE new_car_prices ENABLE ROW LEVEL SECURITY;
-- No public policy — only the service role (used server-side) reads/writes
-- this table, same as the rest of the scoring pipeline's internal tables.


-- ============================================================
-- Migration: depreciation_curves (empirical value-retention curve)
-- Run this once in Supabase Dashboard → SQL Editor → New Query
-- ============================================================
-- Replaces the flat, hand-guessed `depreciation` % per model in
-- data/referenceData.ts with an empirically measured curve: for a given
-- (brand, model, generation, age in years), what fraction of the car's
-- ORIGINAL new price (from new_car_prices, at the vintage it was actually
-- built) does the market still pay for it today? Computed by
-- pages/api/admin/recompute-depreciation-curves.ts from market_listings +
-- new_car_prices. year_from mirrors the referenceData.ts generation's
-- yearFrom so two generations of the same model name (e.g. an older vs.
-- newer XC60) aren't averaged together as if they were the same car.
--
-- calculateOwnershipCosts() derives the year-over-year rate from two
-- consecutive retained_pct points; falls back to referenceData.ts's flat
-- rate for any age transition without enough samples here.

CREATE TABLE depreciation_curves (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand        TEXT NOT NULL,
  model        TEXT NOT NULL,
  year_from    INT NOT NULL,    -- which referenceData.ts generation this covers
  age_years    INT NOT NULL,
  retained_pct NUMERIC NOT NULL,  -- observed median price ÷ Skatteverket new price for that vintage
  sample_size  INT NOT NULL,      -- how many market_listings rows fed the median
  computed_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE (brand, model, year_from, age_years)
);

CREATE INDEX ON depreciation_curves (brand, model, year_from);

ALTER TABLE depreciation_curves ENABLE ROW LEVEL SECURITY;
-- No public policy — only the service role (used server-side) reads/writes
-- this table, same as the rest of the scoring pipeline's internal tables.


-- ============================================================
-- Migration: analyses.median_source
-- Run this once in Supabase Dashboard → SQL Editor → New Query
-- ============================================================
-- Existing analyses table already deployed — this ALTER adds the column
-- for databases created before this migration (a fresh CREATE TABLE
-- analyses already includes it, see above). Distinguishes a real market
-- median from Skatteverket's new-car list price (essentially-new cars),
-- which the price card and pros/cons text now label differently.

ALTER TABLE analyses ADD COLUMN IF NOT EXISTS median_source TEXT
  CHECK (median_source IN ('market','new_car_list')) DEFAULT 'market';


-- ============================================================
-- Migration: analyses.median_source — add 'theoretical'
-- Run this once in Supabase Dashboard → SQL Editor → New Query
-- ============================================================
-- calculatePricing() in engine.ts gained a third medianSource value
-- ('theoretical', for cars with neither a market median nor a new-car
-- list price) but the CHECK constraint above was never widened to
-- match — every save for a car that hit the theoretical fallback path
-- failed with a silent constraint violation (surfaced to the user as
-- a generic "Misslyckades att spara" with no logged cause, since
-- process.ts's save catch-block discarded the real error message —
-- also fixed). ADD COLUMN IF NOT EXISTS is a no-op here since the
-- column already exists; the constraint itself must be dropped and
-- recreated, and its auto-generated name isn't guaranteed, hence the
-- dynamic lookup.

DO $$
DECLARE
  con_name text;
BEGIN
  SELECT con.conname INTO con_name
  FROM pg_constraint con
  JOIN pg_class rel ON rel.oid = con.conrelid
  JOIN pg_attribute att ON att.attrelid = rel.oid AND att.attnum = ANY(con.conkey)
  WHERE rel.relname = 'analyses' AND att.attname = 'median_source' AND con.contype = 'c';

  IF con_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE analyses DROP CONSTRAINT %I', con_name);
  END IF;

  ALTER TABLE analyses ADD CONSTRAINT analyses_median_source_check
    CHECK (median_source IN ('market','new_car_list','theoretical'));
END $$;


-- ============================================================
-- Migration: mileage_sensitivity (steg 3 av värdeminskningskurve-projektet)
-- Run this once in Supabase Dashboard → SQL Editor → New Query
-- ============================================================
-- Hur mycket priset avviker per 1000 mil avvikelse från förväntad
-- mätarställning (ref.avgMilPerYear × ålder), inom samma åldersgrupp —
-- separerar mätarställningens effekt från åldern istället för att låta
-- den vara brus i depreciation_curves medianer. Ett värde per
-- (brand, model, year_from), inte per ålder — beräknas genom att poola
-- alla annonser (alla åldrar) för samma referenspost och regrediera
-- prisavvikelse mot mätarställningsavvikelse. Beräknas av
-- pages/api/admin/recompute-depreciation-curves.ts (samma endpoint,
-- samma data redan hämtad per ålder).

CREATE TABLE mileage_sensitivity (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand                   TEXT NOT NULL,
  model                   TEXT NOT NULL,
  year_from               INT NOT NULL,
  kr_per_1000_mil_deviation NUMERIC NOT NULL,  -- normalt negativt: mer mil än förväntat -> lägre pris
  sample_size             INT NOT NULL,        -- summan av annonser över alla åldersgrupper
  computed_at             TIMESTAMPTZ DEFAULT now(),
  UNIQUE (brand, model, year_from)
);

CREATE INDEX ON mileage_sensitivity (brand, model, year_from);

ALTER TABLE mileage_sensitivity ENABLE ROW LEVEL SECURITY;
-- No public policy — only the service role (used server-side) reads/writes
-- this table, same as the rest of the scoring pipeline's internal tables.


-- ============================================================
-- Migration: get_market_median() — MAD-robust version
-- Run this once in Supabase Dashboard → SQL Editor → New Query
-- ============================================================
-- Investigated 2026-08-12 after finding market_listings groups with huge
-- min/max spread (up to 5x within the same brand/model/year). Checked the
-- actual listings behind three worst cases: a likely ex-taxi Mercedes
-- E-klass (830 000 km, priced consistently with its condition — not an
-- error), a genuinely wide market for high-mileage diesel VW Passats (no
-- error, just real spread), and a BMW M3 (chassis code "F80") lumped into
-- the plain "3-serie" bucket alongside ordinary 320d Tourings (a real
-- classification mismatch, not a data error).
--
-- The plain median (PERCENTILE_CONT(0.5)) turned out to already be fairly
-- robust to single tail extremes — that's the whole point of a median vs.
-- a mean. Manually recomputing it for the E-klass case landed right in
-- the middle of the normal-trim cluster, unmoved by the taxi or the AMG S.
-- The real weak spot is SMALL SAMPLES: with only MIN_LIVE_MEDIAN_SAMPLE_SIZE
-- (5, in lib/supabase/client.ts) listings, an unusual one can BE the
-- middle-ranked value directly, with no other listings around it to
-- buffer the estimate.
--
-- Fix: a two-pass MAD (median absolute deviation) outlier filter before
-- taking the final median. First compute a preliminary median, then MAD
-- (the median of each listing's absolute deviation from that preliminary
-- median — itself robust, unlike a standard deviation), then exclude any
-- listing whose price is more than MAD_THRESHOLD "modified z-score" units
-- away (the 1.4826 constant scales MAD to be comparable to a normal
-- distribution's standard deviation; 3.5 is the conventional threshold
-- from Iglewicz & Hoya's modified z-score method) before recomputing the
-- median on what's left. Returns the FILTERED sample_size (not the raw
-- count) so the existing MIN_LIVE_MEDIAN_SAMPLE_SIZE check in
-- getMarketMedian() reflects how much data the returned median is
-- actually resting on.

CREATE OR REPLACE FUNCTION get_market_median(
  p_brand TEXT,
  p_model TEXT,
  p_year  INT
)
RETURNS TABLE (median NUMERIC, sample_size BIGINT)
LANGUAGE SQL STABLE AS $$
  WITH base AS (
    SELECT price_sek
    FROM market_listings
    WHERE
      LOWER(brand) = LOWER(p_brand)
      AND LOWER(model) = LOWER(p_model)
      AND year = p_year
      AND scraped_at > NOW() - INTERVAL '90 days'
      AND sold_at IS NULL
      AND price_sek > 0
  ),
  prelim AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_sek) AS prelim_median
    FROM base
  ),
  mad AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ABS(base.price_sek - prelim.prelim_median)) AS mad_value
    FROM base, prelim
  ),
  filtered AS (
    SELECT base.price_sek
    FROM base, prelim, mad
    WHERE mad.mad_value = 0
       OR ABS(base.price_sek - prelim.prelim_median) <= 3.5 * 1.4826 * mad.mad_value
  )
  SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_sek)::NUMERIC AS median,
    COUNT(*) AS sample_size
  FROM filtered;
$$;
