"""Read-only connection to the production Supabase pooler.

The password lives in the repo-root `.env` (gitignored), never here.
Every query in this folder is an aggregate — no per-user rows are read.
"""
import re
from pathlib import Path

import psycopg

REPO = Path(__file__).resolve().parents[2]
HOST = "aws-1-eu-central-1.pooler.supabase.com"
USER = "postgres.jlmkkeijmmnwkizutvkg"


def connect():
    env = REPO / ".env"
    if not env.exists():
        raise SystemExit(f"missing {env} — see docs/analytics/README.md")
    password = re.search(r":\s*(\S+)", env.read_text(encoding="utf-8-sig"))
    if not password:
        raise SystemExit(f"no password found in {env}")
    return psycopg.connect(
        host=HOST,
        port=5432,
        user=USER,
        password=password.group(1),
        dbname="postgres",
        sslmode="require",
    )
