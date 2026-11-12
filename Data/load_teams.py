"""
Load Conference, Stadium, and Team tables from the CollegeFootballData.com API.

Setup:
    pip install requests pyodbc
    Copy .env.example to .env (same folder as this file) and fill in:
        CFBD_API_KEY     your CollegeFootballData.com key
        CFB_DB_PASSWORD  the SQL login's password
    Run AlterForApiLoad.sql once against the database.

Run order: load_teams.py, then load_games.py, then load_rosters.py.
"""
import json
import os
from pathlib import Path

import pyodbc
import requests

HERE = Path(__file__).resolve().parent
CACHE_DIR = HERE / "cache"  # raw API responses, so re-runs don't spend API calls


def _load_env_file(path=HERE / ".env"):
    """Read KEY=value lines from .env into os.environ (real env vars win)."""
    if not path.exists():
        return
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


_load_env_file()

API_KEY = os.environ.get("CFBD_API_KEY", "")
DB_PASSWORD = os.environ.get("CFB_DB_PASSWORD", "")

CONN_STR = (
    "Driver={ODBC Driver 18 for SQL Server};"
    "Server=mist353f26parshley-server.database.windows.net;"
    "Database=CollegeFootball_RDB_Parshley;"
    "Uid=NandaSurendra;"
    f"Pwd={{{DB_PASSWORD.replace('}', '}}')}}};"
    "Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
)

BASE_URL = "https://api.collegefootballdata.com"
HEADERS = {"Authorization": f"Bearer {API_KEY}", "Accept": "application/json"}

# The API filters by conference ABBREVIATION
CONFERENCES = ["SEC", "B1G", "B12", "ACC"]
YEAR = 2026  # season whose conference membership you want

SAVE_RAW_JSON = True  # keep a local copy so re-runs don't spend API calls


def check_settings():
    """Stop with a clear message if the key or password hasn't been set."""
    missing = [
        name
        for name, value in (("CFBD_API_KEY", API_KEY), ("CFB_DB_PASSWORD", DB_PASSWORD))
        if not value
    ]
    if missing:
        raise SystemExit(
            f"Missing {' and '.join(missing)}. Put them in {HERE / '.env'} "
            "(see .env.example) or set them as environment variables."
        )


def cache_path(filename):
    CACHE_DIR.mkdir(exist_ok=True)
    return CACHE_DIR / filename


def fetch_teams(conference):
    cache_file = cache_path(f"teams_{conference}_{YEAR}.json")
    if cache_file.exists():
        with open(cache_file) as f:
            return json.load(f)

    resp = requests.get(
        f"{BASE_URL}/teams",
        headers=HEADERS,
        params={"conference": conference, "year": YEAR},
        timeout=30,
    )
    resp.raise_for_status()
    data = resp.json()

    if SAVE_RAW_JSON:
        with open(cache_file, "w") as f:
            json.dump(data, f, indent=2)
    return data


def get_or_create_conference(cur, name):
    cur.execute("SELECT ConferenceID FROM Conference WHERE ConferenceName = ?", name)
    row = cur.fetchone()
    if row:
        return row[0]
    cur.execute(
        "INSERT INTO Conference (ConferenceName) OUTPUT INSERTED.ConferenceID VALUES (?)",
        name,
    )
    return cur.fetchone()[0]


def get_or_create_stadium(cur, loc):
    # The API has no street address, so StadiumStreetAddress is left NULL
    # (AlterForApiLoad.sql makes that column nullable).
    name = (loc.get("name") or "Unknown Stadium")[:50]
    city = (loc.get("city") or "Unknown")[:50]
    state = (loc.get("state") or "NA")[:2]
    capacity = loc.get("capacity") or 0
    field = "Grass" if loc.get("grass") else "Artificial Turf"

    cur.execute(
        "SELECT StadiumID FROM Stadium "
        "WHERE StadiumName = ? AND StadiumCity = ? AND StadiumState = ?",
        name, city, state,
    )
    row = cur.fetchone()
    if row:
        return row[0]
    cur.execute(
        "INSERT INTO Stadium (StadiumName, StadiumCity, StadiumState, StadiumCapacity, TypeOfField) "
        "OUTPUT INSERTED.StadiumID VALUES (?, ?, ?, ?, ?)",
        name, city, state, capacity, field,
    )
    return cur.fetchone()[0]


def insert_team(cur, university, mascot, stadium_id, conference_id):
    cur.execute("SELECT TeamID FROM Team WHERE UniversityName = ?", university)
    if cur.fetchone():
        return False  # already loaded
    cur.execute(
        "INSERT INTO Team (UniversityName, TeamName, StadiumID, ConferenceID) VALUES (?, ?, ?, ?)",
        university, mascot, stadium_id, conference_id,
    )
    return True


def main():
    check_settings()
    conn = pyodbc.connect(CONN_STR)
    cur = conn.cursor()

    for conf in CONFERENCES:
        teams = fetch_teams(conf)
        print(f"{conf}: {len(teams)} teams returned")

        for t in teams:
            conf_name = t.get("conference") or conf  # e.g. "Big Ten" rather than "B1G"
            conference_id = get_or_create_conference(cur, conf_name[:50])
            stadium_id = get_or_create_stadium(cur, t.get("location") or {})
            added = insert_team(
                cur,
                t["school"][:50],
                (t.get("mascot") or t["school"])[:50],
                stadium_id,
                conference_id,
            )
            print(f"   {'added' if added else 'skipped'}: {t['school']}")

        conn.commit()

    cur.close()
    conn.close()
    print("Done.")


if __name__ == "__main__":
    main()
