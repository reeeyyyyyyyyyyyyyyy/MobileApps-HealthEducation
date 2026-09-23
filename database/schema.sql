-- ============================================
-- UtiCare Database Schema
-- Aplikasi Pencegahan ISK untuk Remaja Putri
-- ============================================

-- 1. Profiles
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  age INTEGER,
  school TEXT,
  class TEXT,
  phone TEXT,
  has_completed_pretest BOOLEAN DEFAULT FALSE,
  has_completed_posttest BOOLEAN DEFAULT FALSE,
  pretest_completed_at TIMESTAMPTZ,
  posttest_completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT TO authenticated USING ((SELECT auth.uid()) = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT TO authenticated WITH CHECK ((SELECT auth.uid()) = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE TO authenticated USING ((SELECT auth.uid()) = id) WITH CHECK ((SELECT auth.uid()) = id);

-- 2. Education Materials
CREATE TABLE IF NOT EXISTS education_materials (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'pengetahuan_isk',
  content TEXT,
  video_url TEXT,
  thumbnail_url TEXT,
  hbm_component TEXT,
  view_count INTEGER DEFAULT 0,
  published SMALLINT DEFAULT 0,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE education_materials ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read published materials" ON education_materials FOR SELECT TO authenticated USING (published = 1);
CREATE POLICY "Service role full access materials" ON education_materials FOR ALL TO service_role USING (true);

-- 3. Risk Questions
CREATE TABLE IF NOT EXISTS risk_questions (
  id BIGSERIAL PRIMARY KEY,
  question_text TEXT NOT NULL,
  question_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE risk_questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read active risk questions" ON risk_questions FOR SELECT TO authenticated USING (is_active = true);
CREATE POLICY "Service role full access risk_questions" ON risk_questions FOR ALL TO service_role USING (true);

-- 4. Risk Options
CREATE TABLE IF NOT EXISTS risk_options (
  id BIGSERIAL PRIMARY KEY,
  question_id BIGINT REFERENCES risk_questions(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  score INTEGER DEFAULT 0,
  option_order INTEGER DEFAULT 0
);

ALTER TABLE risk_options ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read risk options" ON risk_options FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service role full access risk_options" ON risk_options FOR ALL TO service_role USING (true);

-- 5. Risk Results
CREATE TABLE IF NOT EXISTS risk_results (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  total_score INTEGER,
  risk_level TEXT,
  answers JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE risk_results ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own risk results" ON risk_results FOR SELECT TO authenticated USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "Users can insert own risk results" ON risk_results FOR INSERT TO authenticated WITH CHECK ((SELECT auth.uid()) = user_id);

-- 6. Daily Habits
CREATE TABLE IF NOT EXISTS daily_habits (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  log_date DATE NOT NULL,
  water_intake INTEGER DEFAULT 0,
  no_hold_urine BOOLEAN DEFAULT FALSE,
  genital_hygiene TEXT DEFAULT 'baik',
  physical_activity INTEGER DEFAULT 0,
  habit_score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, log_date)
);

ALTER TABLE daily_habits ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own habits" ON daily_habits FOR SELECT TO authenticated USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "Users can insert own habits" ON daily_habits FOR INSERT TO authenticated WITH CHECK ((SELECT auth.uid()) = user_id);
CREATE POLICY "Users can update own habits" ON daily_habits FOR UPDATE TO authenticated USING ((SELECT auth.uid()) = user_id) WITH CHECK ((SELECT auth.uid()) = user_id);

-- 7. Reminder Templates
CREATE TABLE IF NOT EXISTS reminder_templates (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  default_time TIME DEFAULT '08:00:00',
  icon_name TEXT DEFAULT 'notifications',
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE reminder_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read active reminders" ON reminder_templates FOR SELECT TO authenticated USING (is_active = true);
CREATE POLICY "Service role full access reminders" ON reminder_templates FOR ALL TO service_role USING (true);

-- 8. User Reminders
CREATE TABLE IF NOT EXISTS user_reminders (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  template_id BIGINT REFERENCES reminder_templates(id) ON DELETE CASCADE,
  scheduled_time TIME NOT NULL,
  is_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE user_reminders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own reminders" ON user_reminders FOR SELECT TO authenticated USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "Users can insert own reminders" ON user_reminders FOR INSERT TO authenticated WITH CHECK ((SELECT auth.uid()) = user_id);
CREATE POLICY "Users can update own reminders" ON user_reminders FOR UPDATE TO authenticated USING ((SELECT auth.uid()) = user_id) WITH CHECK ((SELECT auth.uid()) = user_id);

-- 9. Survey Instruments (Pre-test / Post-test)
CREATE TABLE IF NOT EXISTS survey_instruments (
  id BIGSERIAL PRIMARY KEY,
  type TEXT NOT NULL, -- 'pretest', 'posttest'
  variable TEXT NOT NULL, -- 'pengetahuan', 'sikap', 'perilaku'
  question_text TEXT NOT NULL,
  question_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE survey_instruments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read active instruments" ON survey_instruments FOR SELECT TO authenticated USING (is_active = true);
CREATE POLICY "Service role full access instruments" ON survey_instruments FOR ALL TO service_role USING (true);

-- 10. Survey Options
CREATE TABLE IF NOT EXISTS survey_options (
  id BIGSERIAL PRIMARY KEY,
  instrument_id BIGINT REFERENCES survey_instruments(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  score INTEGER DEFAULT 0,
  option_order INTEGER DEFAULT 0
);

ALTER TABLE survey_options ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read survey options" ON survey_options FOR SELECT TO authenticated USING (true);
CREATE POLICY "Service role full access survey_options" ON survey_options FOR ALL TO service_role USING (true);

-- 11. Survey Responses
CREATE TABLE IF NOT EXISTS survey_responses (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  instrument_id BIGINT REFERENCES survey_instruments(id) ON DELETE CASCADE,
  selected_option_id BIGINT REFERENCES survey_options(id),
  type TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, instrument_id, type)
);

ALTER TABLE survey_responses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own responses" ON survey_responses FOR SELECT TO authenticated USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "Users can insert own responses" ON survey_responses FOR INSERT TO authenticated WITH CHECK ((SELECT auth.uid()) = user_id);

-- 12. Daily Tips
CREATE TABLE IF NOT EXISTS daily_tips (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT DEFAULT 'umum',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE daily_tips ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read active tips" ON daily_tips FOR SELECT TO authenticated USING (is_active = true);
CREATE POLICY "Service role full access tips" ON daily_tips FOR ALL TO service_role USING (true);

-- 13. User Bookmarks
CREATE TABLE IF NOT EXISTS user_bookmarks (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  material_id BIGINT REFERENCES education_materials(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, material_id)
);

ALTER TABLE user_bookmarks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own bookmarks" ON user_bookmarks FOR SELECT TO authenticated USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "Users can insert own bookmarks" ON user_bookmarks FOR INSERT TO authenticated WITH CHECK ((SELECT auth.uid()) = user_id);
CREATE POLICY "Users can delete own bookmarks" ON user_bookmarks FOR DELETE TO authenticated USING ((SELECT auth.uid()) = user_id);

-- 14. User Progress
CREATE TABLE IF NOT EXISTS user_progress (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  material_id BIGINT REFERENCES education_materials(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, material_id)
);

ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own progress" ON user_progress FOR SELECT TO authenticated USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "Users can insert own progress" ON user_progress FOR INSERT TO authenticated WITH CHECK ((SELECT auth.uid()) = user_id);

-- ============================================
-- TRIGGER: Auto-create profile on signup
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data ->> 'full_name');
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- GRANT access for Data API
-- ============================================
GRANT SELECT ON profiles TO authenticated;
GRANT INSERT ON profiles TO authenticated;
GRANT UPDATE ON profiles TO authenticated;
GRANT SELECT ON education_materials TO authenticated;
GRANT SELECT ON risk_questions TO authenticated;
GRANT SELECT ON risk_options TO authenticated;
GRANT SELECT, INSERT ON risk_results TO authenticated;
GRANT SELECT, INSERT, UPDATE ON daily_habits TO authenticated;
GRANT SELECT ON reminder_templates TO authenticated;
GRANT SELECT, INSERT, UPDATE ON user_reminders TO authenticated;
GRANT SELECT ON survey_instruments TO authenticated;
GRANT SELECT ON survey_options TO authenticated;
GRANT SELECT, INSERT ON survey_responses TO authenticated;
GRANT SELECT ON daily_tips TO authenticated;
GRANT SELECT, INSERT, DELETE ON user_bookmarks TO authenticated;
GRANT SELECT, INSERT ON user_progress TO authenticated;

-- Grant sequences for inserts
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;
