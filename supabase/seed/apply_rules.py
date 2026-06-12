"""Apply supabase/seed/plant_task_rules.sql to the cloud (one-off / on growth).
Runs as the project postgres role via the session pooler (bypasses RLS, which
only blocks client writes). Reads the DB password from .env (gitignored).
Idempotent. Regenerate the SQL first: dart run tool/gen_rules_sql.dart"""
import re
import psycopg

pwd = re.search(r":\s*(\S+)", open(".env", encoding="utf-8-sig").read()).group(1)
sql = open("supabase/seed/plant_task_rules.sql", encoding="utf-8").read()

conn = psycopg.connect(
    host="aws-1-eu-central-1.pooler.supabase.com",
    port=5432,
    user="postgres.jlmkkeijmmnwkizutvkg",
    password=pwd,
    dbname="postgres",
    sslmode="require",
)
with conn.cursor() as cur:
    cur.execute(sql)
conn.commit()
with conn.cursor() as cur:
    cur.execute("select count(*) from plant_task_rule")
    (n,) = cur.fetchone()
    print(f"cloud plant_task_rule: {n} rows")
conn.close()
