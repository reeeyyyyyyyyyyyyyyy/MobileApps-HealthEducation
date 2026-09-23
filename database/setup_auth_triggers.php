<?php

$dsn = "pgsql:host=db.lvvftnvgdwdkoyxjskkj.supabase.co;port=5432;dbname=postgres;sslmode=require";
$pdo = new PDO($dsn, "postgres", "BismillahLancar", [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

$sql = <<<SQL
CREATE OR REPLACE FUNCTION public.auto_confirm_new_users()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS \$\$
BEGIN
  NEW.email_confirmed_at = COALESCE(NEW.email_confirmed_at, NOW());
  NEW.confirmed_at = COALESCE(NEW.confirmed_at, NOW());
  RETURN NEW;
END;
\$\$;

DROP TRIGGER IF EXISTS on_auth_user_created_confirm ON auth.users;
CREATE TRIGGER on_auth_user_created_confirm
  BEFORE INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_new_users();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS \$\$
BEGIN
  INSERT INTO public.profiles (id, full_name, school, class, age, phone)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
    NEW.raw_user_meta_data ->> 'school',
    NEW.raw_user_meta_data ->> 'class',
    CASE WHEN (NEW.raw_user_meta_data ->> 'age') ~ '^[0-9]+$' THEN (NEW.raw_user_meta_data ->> 'age')::integer ELSE NULL END,
    NEW.raw_user_meta_data ->> 'phone'
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    school = COALESCE(EXCLUDED.school, public.profiles.school),
    class = COALESCE(EXCLUDED.class, public.profiles.class),
    age = COALESCE(EXCLUDED.age, public.profiles.age),
    phone = COALESCE(EXCLUDED.phone, public.profiles.phone);
  RETURN NEW;
END;
\$\$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
SQL;

$pdo->exec($sql);
echo "Auth trigger & profile sync successfully created on Supabase!\n";
