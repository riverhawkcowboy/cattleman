-- Smoke test for database/migrations/0001_init.sql.
BEGIN;

DO $$
DECLARE
  county_id UUID;
  program_year_id UUID;
  cohort_id UUID;
  person_id UUID;
  enrollment_id UUID;
  discipline_id UUID;
  chapter_id UUID;
  quiz_id UUID;
  question_id UUID;
  attempt_id UUID;
  answer_id UUID;
  credit_id UUID;
  audit_id UUID;
  blocked BOOLEAN;
  rejected BOOLEAN;
  table_name TEXT;
BEGIN
  IF to_regclass('public.counties') IS NULL
     OR to_regclass('public.certification_evaluations') IS NULL
     OR to_regclass('public.audit_logs') IS NULL THEN
    RAISE EXCEPTION 'Expected migration tables are missing';
  END IF;

  IF to_regclass('public.idx_earned_credits_enrollment_awarded_at') IS NULL THEN
    RAISE EXCEPTION 'Expected reporting index is missing';
  END IF;

  INSERT INTO counties (name, code) VALUES ('Migration smoke test', 'MIGTEST')
    RETURNING id INTO county_id;
  INSERT INTO program_years (label, start_date, end_date)
    VALUES ('Migration smoke test', DATE '2026-01-01', DATE '2026-12-31')
    RETURNING id INTO program_year_id;
  INSERT INTO cohorts (county_id, program_year_id, name)
    VALUES (county_id, program_year_id, 'Migration smoke test')
    RETURNING id INTO cohort_id;
  INSERT INTO persons (county_id, first_name, last_name)
    VALUES (county_id, 'Migration', 'Tester')
    RETURNING id INTO person_id;
  INSERT INTO enrollments (person_id, cohort_id)
    VALUES (person_id, cohort_id)
    RETURNING id INTO enrollment_id;
  INSERT INTO disciplines (name) VALUES ('Migration smoke test')
    RETURNING id INTO discipline_id;
  INSERT INTO chapters (discipline_id, code, title, chapter_type)
    VALUES (discipline_id, 'MIGTEST', 'Migration smoke test', 'core')
    RETURNING id INTO chapter_id;
  INSERT INTO quizzes (chapter_id, title)
    VALUES (chapter_id, 'Migration smoke test')
    RETURNING id INTO quiz_id;
  INSERT INTO questions (quiz_id, prompt, question_type, position)
    VALUES (quiz_id, 'Migration smoke test?', 'true_false', 1)
    RETURNING id INTO question_id;
  INSERT INTO assessment_attempts
    (quiz_id, person_id, enrollment_id, attempt_no, score, max_score, passed)
    VALUES (quiz_id, person_id, enrollment_id, 1, 0, 1, FALSE)
    RETURNING id INTO attempt_id;
  INSERT INTO attempt_answers (attempt_id, question_id)
    VALUES (attempt_id, question_id)
    RETURNING id INTO answer_id;
  INSERT INTO earned_credits (person_id, enrollment_id, credit_source, hours_earned)
    VALUES (person_id, enrollment_id, 'manual_override', 1)
    RETURNING id INTO credit_id;
  INSERT INTO audit_logs (action, object_type, object_id)
    VALUES ('migration smoke test', 'person', person_id)
    RETURNING id INTO audit_id;

  rejected := FALSE;
  BEGIN
    INSERT INTO program_years (label, start_date, end_date)
      VALUES ('Invalid date range smoke test', DATE '2026-12-31', DATE '2026-01-01');
  EXCEPTION WHEN check_violation THEN
    rejected := TRUE;
  END;
  IF NOT rejected THEN
    RAISE EXCEPTION 'Program year date check constraint did not reject an invalid range';
  END IF;

  FOREACH table_name IN ARRAY ARRAY['assessment_attempts', 'attempt_answers', 'earned_credits', 'audit_logs']
  LOOP
    IF NOT EXISTS (
      SELECT 1 FROM pg_trigger
      WHERE tgrelid = format('public.%I', table_name)::regclass
        AND tgname = CASE table_name
          WHEN 'assessment_attempts' THEN 'trg_assessment_attempts_no_update'
          WHEN 'attempt_answers' THEN 'trg_attempt_answers_no_update'
          WHEN 'earned_credits' THEN 'trg_earned_credits_no_update'
          ELSE 'trg_audit_logs_no_update'
        END
        AND NOT tgisinternal
    ) THEN
      RAISE EXCEPTION 'Append-only trigger missing on %', table_name;
    END IF;
  END LOOP;

  blocked := FALSE;
  BEGIN
    UPDATE assessment_attempts SET score = 1 WHERE id = attempt_id;
  EXCEPTION WHEN OTHERS THEN
    blocked := SQLERRM = 'Table assessment_attempts is immutable; use compensating records';
  END;
  IF NOT blocked THEN RAISE EXCEPTION 'assessment_attempts update was not blocked'; END IF;
  blocked := FALSE;
  BEGIN
    DELETE FROM assessment_attempts WHERE id = attempt_id;
  EXCEPTION WHEN OTHERS THEN
    blocked := SQLERRM = 'Table assessment_attempts is immutable; use compensating records';
  END;
  IF NOT blocked THEN RAISE EXCEPTION 'assessment_attempts delete was not blocked'; END IF;

  blocked := FALSE;
  BEGIN
    DELETE FROM attempt_answers WHERE id = answer_id;
  EXCEPTION WHEN OTHERS THEN
    blocked := SQLERRM = 'Table attempt_answers is immutable; use compensating records';
  END;
  IF NOT blocked THEN RAISE EXCEPTION 'attempt_answers delete was not blocked'; END IF;
  blocked := FALSE;
  BEGIN
    UPDATE attempt_answers SET answer_payload = '{"test":true}'::jsonb WHERE id = answer_id;
  EXCEPTION WHEN OTHERS THEN
    blocked := SQLERRM = 'Table attempt_answers is immutable; use compensating records';
  END;
  IF NOT blocked THEN RAISE EXCEPTION 'attempt_answers update was not blocked'; END IF;

  blocked := FALSE;
  BEGIN
    UPDATE earned_credits SET hours_earned = 2 WHERE id = credit_id;
  EXCEPTION WHEN OTHERS THEN
    blocked := SQLERRM = 'Table earned_credits is immutable; use compensating records';
  END;
  IF NOT blocked THEN RAISE EXCEPTION 'earned_credits update was not blocked'; END IF;
  blocked := FALSE;
  BEGIN
    DELETE FROM earned_credits WHERE id = credit_id;
  EXCEPTION WHEN OTHERS THEN
    blocked := SQLERRM = 'Table earned_credits is immutable; use compensating records';
  END;
  IF NOT blocked THEN RAISE EXCEPTION 'earned_credits delete was not blocked'; END IF;

  blocked := FALSE;
  BEGIN
    DELETE FROM audit_logs WHERE id = audit_id;
  EXCEPTION WHEN OTHERS THEN
    blocked := SQLERRM = 'Table audit_logs is immutable; use compensating records';
  END;
  IF NOT blocked THEN RAISE EXCEPTION 'audit_logs delete was not blocked'; END IF;
  blocked := FALSE;
  BEGIN
    UPDATE audit_logs SET reason = 'attempted mutation' WHERE id = audit_id;
  EXCEPTION WHEN OTHERS THEN
    blocked := SQLERRM = 'Table audit_logs is immutable; use compensating records';
  END;
  IF NOT blocked THEN RAISE EXCEPTION 'audit_logs update was not blocked'; END IF;
END $$;

ROLLBACK;
