-- Master Cattleman modernization schema (PostgreSQL)

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TYPE user_status AS ENUM ('active', 'inactive', 'locked');
CREATE TYPE county_access_scope AS ENUM ('primary', 'secondary', 'supervisory');
CREATE TYPE program_year_status AS ENUM ('planned', 'active', 'closed', 'archived');
CREATE TYPE cohort_status AS ENUM ('planned', 'active', 'completed', 'archived');
CREATE TYPE person_status AS ENUM ('active', 'inactive');
CREATE TYPE enrollment_status AS ENUM ('active', 'completed', 'withdrawn', 'archived');
CREATE TYPE chapter_type AS ENUM ('core', 'elective');
CREATE TYPE asset_type AS ENUM ('pdf', 'ppt', 'video', 'link', 'other');
CREATE TYPE assignment_type AS ENUM ('core_auto', 'elective', 'manual');
CREATE TYPE credit_source AS ENUM ('chapter', 'session', 'manual_override');
CREATE TYPE consent_status AS ENUM ('granted', 'revoked', 'unknown');
CREATE TYPE question_type AS ENUM ('single_choice', 'multi_choice', 'true_false', 'free_text');

CREATE TABLE counties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email CITEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  status user_status NOT NULL DEFAULT 'active',
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE role_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (role_id, permission_id)
);

CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, role_id)
);

CREATE TABLE user_county_access (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  county_id UUID NOT NULL REFERENCES counties(id) ON DELETE CASCADE,
  scope county_access_scope NOT NULL DEFAULT 'primary',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, county_id)
);

CREATE TABLE program_years (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL UNIQUE,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status program_year_status NOT NULL DEFAULT 'planned',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (end_date >= start_date)
);

CREATE TABLE cohorts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  county_id UUID NOT NULL REFERENCES counties(id),
  program_year_id UUID NOT NULL REFERENCES program_years(id),
  name TEXT NOT NULL,
  status cohort_status NOT NULL DEFAULT 'planned',
  start_date DATE,
  end_date DATE,
  archived_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
  UNIQUE (county_id, program_year_id, name)
);

CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  county_id UUID REFERENCES counties(id),
  name TEXT NOT NULL,
  organization_type TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE persons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  county_id UUID NOT NULL REFERENCES counties(id),
  organization_id UUID REFERENCES organizations(id),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  preferred_name TEXT,
  email CITEXT,
  phone TEXT,
  address_line1 TEXT,
  address_line2 TEXT,
  city TEXT,
  state_code TEXT,
  postal_code TEXT,
  demographic_json JSONB NOT NULL DEFAULT '{}'::jsonb,
  status person_status NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE person_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id UUID NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  author_user_id UUID REFERENCES users(id),
  note_type TEXT NOT NULL DEFAULT 'note',
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  category TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE person_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id UUID NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (person_id, tag_id)
);

CREATE TABLE consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id UUID NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  consent_type TEXT NOT NULL,
  status consent_status NOT NULL,
  source TEXT,
  effective_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id UUID NOT NULL REFERENCES persons(id),
  cohort_id UUID NOT NULL REFERENCES cohorts(id),
  status enrollment_status NOT NULL DEFAULT 'active',
  enrolled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ,
  completion_override_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (person_id, cohort_id)
);

CREATE TABLE disciplines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  is_core BOOLEAN NOT NULL DEFAULT FALSE,
  display_order INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE chapters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discipline_id UUID NOT NULL REFERENCES disciplines(id),
  code TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  chapter_type chapter_type NOT NULL,
  description TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE chapter_credit_hours (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chapter_id UUID NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
  hours NUMERIC(5,2) NOT NULL CHECK (hours >= 0),
  effective_start DATE NOT NULL,
  effective_end DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (effective_end IS NULL OR effective_end >= effective_start)
);

CREATE TABLE assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chapter_id UUID NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  asset_type asset_type NOT NULL DEFAULT 'other',
  storage_url TEXT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE cohort_chapter_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cohort_id UUID NOT NULL REFERENCES cohorts(id) ON DELETE CASCADE,
  chapter_id UUID NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
  assignment_type assignment_type NOT NULL,
  assigned_by_user_id UUID REFERENCES users(id),
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (cohort_id, chapter_id)
);

CREATE TABLE cohort_asset_access (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cohort_id UUID NOT NULL REFERENCES cohorts(id) ON DELETE CASCADE,
  asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
  is_visible BOOLEAN NOT NULL DEFAULT TRUE,
  configured_by_user_id UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (cohort_id, asset_id)
);

CREATE TABLE quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chapter_id UUID NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE quiz_thresholds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  passing_score NUMERIC(6,2) NOT NULL CHECK (passing_score >= 0),
  effective_start TIMESTAMPTZ NOT NULL DEFAULT now(),
  effective_end TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (effective_end IS NULL OR effective_end >= effective_start)
);

CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  prompt TEXT NOT NULL,
  question_type question_type NOT NULL,
  position INTEGER NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (quiz_id, position)
);

CREATE TABLE assessment_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id),
  person_id UUID NOT NULL REFERENCES persons(id),
  enrollment_id UUID REFERENCES enrollments(id),
  attempt_no INTEGER NOT NULL CHECK (attempt_no > 0),
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  submitted_at TIMESTAMPTZ,
  score NUMERIC(6,2) NOT NULL CHECK (score >= 0),
  max_score NUMERIC(6,2) NOT NULL CHECK (max_score > 0),
  passed BOOLEAN NOT NULL,
  grading_payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (quiz_id, person_id, attempt_no)
);

CREATE TABLE attempt_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES assessment_attempts(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id),
  answer_payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  is_correct BOOLEAN,
  awarded_points NUMERIC(6,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (attempt_id, question_id)
);

CREATE TABLE earned_credits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id UUID NOT NULL REFERENCES persons(id),
  enrollment_id UUID NOT NULL REFERENCES enrollments(id),
  chapter_id UUID REFERENCES chapters(id),
  credit_source credit_source NOT NULL,
  hours_earned NUMERIC(6,2) NOT NULL CHECK (hours_earned >= 0),
  awarded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  awarded_by_user_id UUID REFERENCES users(id),
  source_ref TEXT,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE certification_rule_sets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  required_core_hours NUMERIC(6,2) NOT NULL DEFAULT 16,
  required_elective_hours NUMERIC(6,2) NOT NULL DEFAULT 12,
  required_total_hours NUMERIC(6,2) NOT NULL DEFAULT 28,
  required_core_disciplines INTEGER NOT NULL DEFAULT 6,
  requires_quiz_pass BOOLEAN NOT NULL DEFAULT TRUE,
  effective_start DATE NOT NULL,
  effective_end DATE,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (required_core_hours >= 0),
  CHECK (required_elective_hours >= 0),
  CHECK (required_total_hours >= 0),
  CHECK (required_core_disciplines >= 0),
  CHECK (effective_end IS NULL OR effective_end >= effective_start)
);

CREATE TABLE certification_evaluations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id UUID NOT NULL REFERENCES persons(id),
  enrollment_id UUID NOT NULL REFERENCES enrollments(id),
  rule_set_id UUID NOT NULL REFERENCES certification_rule_sets(id),
  core_hours NUMERIC(6,2) NOT NULL,
  elective_hours NUMERIC(6,2) NOT NULL,
  total_hours NUMERIC(6,2) NOT NULL,
  core_disciplines_met_count INTEGER NOT NULL,
  quiz_requirements_met BOOLEAN NOT NULL,
  eligible BOOLEAN NOT NULL,
  unmet_conditions_json JSONB NOT NULL DEFAULT '[]'::jsonb,
  evaluated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE report_exports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  export_type TEXT NOT NULL,
  requested_by_user_id UUID REFERENCES users(id),
  county_id UUID REFERENCES counties(id),
  filter_json JSONB NOT NULL DEFAULT '{}'::jsonb,
  row_count INTEGER NOT NULL DEFAULT 0,
  file_uri TEXT,
  file_checksum TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id UUID REFERENCES users(id),
  action TEXT NOT NULL,
  object_type TEXT NOT NULL,
  object_id UUID,
  county_id UUID REFERENCES counties(id),
  before_json JSONB,
  after_json JSONB,
  reason TEXT,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  request_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Reporting indexes
CREATE INDEX idx_cohorts_county_program_status ON cohorts(county_id, program_year_id, status);
CREATE INDEX idx_enrollments_cohort_status_person ON enrollments(cohort_id, status, person_id);
CREATE INDEX idx_persons_county_status_name ON persons(county_id, status, last_name, first_name);
CREATE INDEX idx_earned_credits_enrollment_awarded_at ON earned_credits(enrollment_id, awarded_at DESC);
CREATE INDEX idx_earned_credits_person_awarded_at ON earned_credits(person_id, awarded_at DESC);
CREATE INDEX idx_assessment_attempts_person_quiz_submitted ON assessment_attempts(person_id, quiz_id, submitted_at DESC);
CREATE INDEX idx_cert_evals_enrollment_evaluated ON certification_evaluations(enrollment_id, evaluated_at DESC);
CREATE INDEX idx_audit_logs_county_occurred ON audit_logs(county_id, occurred_at DESC);
CREATE INDEX idx_audit_logs_actor_occurred ON audit_logs(actor_user_id, occurred_at DESC);
CREATE INDEX idx_report_exports_requester_created ON report_exports(requested_by_user_id, created_at DESC);

-- Frequently joined FKs indexes
CREATE INDEX idx_user_county_access_user ON user_county_access(user_id);
CREATE INDEX idx_user_county_access_county ON user_county_access(county_id);
CREATE INDEX idx_cohorts_program_year ON cohorts(program_year_id);
CREATE INDEX idx_enrollments_person ON enrollments(person_id);
CREATE INDEX idx_person_notes_person ON person_notes(person_id);
CREATE INDEX idx_consents_person ON consents(person_id);
CREATE INDEX idx_chapters_discipline ON chapters(discipline_id);
CREATE INDEX idx_assets_chapter ON assets(chapter_id);
CREATE INDEX idx_quizzes_chapter ON quizzes(chapter_id);
CREATE INDEX idx_questions_quiz ON questions(quiz_id);
CREATE INDEX idx_attempt_answers_attempt ON attempt_answers(attempt_id);
CREATE INDEX idx_cert_evals_person ON certification_evaluations(person_id);

-- Auto-update updated_at helper
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
  t RECORD;
BEGIN
  FOR t IN
    SELECT tablename
    FROM pg_tables
    WHERE schemaname = 'public'
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_updated_at ON %I', t.tablename, t.tablename);
    EXECUTE format('CREATE TRIGGER trg_%I_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION set_updated_at()', t.tablename, t.tablename);
  END LOOP;
END $$;

-- Immutable evidence protections
CREATE OR REPLACE FUNCTION prevent_mutation()
RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'Table % is immutable; use compensating records', TG_TABLE_NAME;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_assessment_attempts_no_update
BEFORE UPDATE OR DELETE ON assessment_attempts
FOR EACH ROW EXECUTE FUNCTION prevent_mutation();

CREATE TRIGGER trg_attempt_answers_no_update
BEFORE UPDATE OR DELETE ON attempt_answers
FOR EACH ROW EXECUTE FUNCTION prevent_mutation();

CREATE TRIGGER trg_earned_credits_no_update
BEFORE UPDATE OR DELETE ON earned_credits
FOR EACH ROW EXECUTE FUNCTION prevent_mutation();

CREATE TRIGGER trg_audit_logs_no_update
BEFORE UPDATE OR DELETE ON audit_logs
FOR EACH ROW EXECUTE FUNCTION prevent_mutation();

COMMIT;
