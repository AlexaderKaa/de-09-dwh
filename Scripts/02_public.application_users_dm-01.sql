DROP TABLE IF EXISTS public.application_users_dm;

CREATE TABLE IF NOT EXISTS public.application_users_dm
(
  id bigint PRIMARY KEY GENERATED ALWAYS AS identity,
  login VARCHAR(32) NOT NULL,
  fullname TEXT NOT NULL,
  age smallint CHECK (age > 14) NOT NULL,
  created_date DATE NOT NULL,
  last_visit_date TIMESTAMPTZ NOT NULL,
  subscription boolean NOT NULL,
  avg_time_in_app_hh NUMERIC NOT NULL,
  day_max_time_in_the_app SMALLINT NOT NULL CHECK (day_max_time_in_the_app > 0 AND day_max_time_in_the_app < 8),
  activity_percentage NUMERIC NOT NULL
  ,CONSTRAINT application_users_dm_pk UNIQUE (id)
);
 