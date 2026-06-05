"""Apply supabase/seed/catalog.sql to the cloud (one-off / on catalog growth).
Runs as the project postgres role via the session pooler (bypasses RLS, which
only blocks client writes). Reads the DB password from .env (gitignored).
Idempotent. Regenerate catalog.sql first: dart run tool/gen_catalog_sql.dart"""
import re
import psycopg

pwd = re.search(r":\s*(\S+)", open(".env", encoding="utf-8-sig").read()).group(1)
sql = open("supabase/seed/catalog.sql", encoding="utf-8").read()

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
    cur.execute(
        "select (select count(*) from task_type), "
        "(select count(*) from plant), "
        "(select count(*) from category_task_type)"
    )
    tt, pl, ct = cur.fetchone()
    print(f"cloud catalog: task_type={tt}, plant={pl}, category_task_type={ct}")
conn.close()
