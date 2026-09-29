#!/usr/bin/env python3
"""Estimate daily work start/end times from this Mac's activity logs.

Usage: work_hours.py [FROM [TO]]   (YYYY-MM-DD, default: today)
"""
import re
import sqlite3
import subprocess
import sys
from datetime import date, datetime
from pathlib import Path

KNOWLEDGE_DB = Path.home() / "Library/Application Support/Knowledge/knowledgeC.db"
MAC_EPOCH_OFFSET = 978307200

PMSET_LINE = re.compile(r"^(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2}) [+-]\d{4} (\S+)\s+(.*)$")
# Sleeps the Mac enters by itself after a brief background wake, not user-driven.
SELF_WAKE_SLEEP = re.compile(r"Maintenance Sleep|Back to Sleep")


def parse_args(argv):
    try:
        days = [date.fromisoformat(a) for a in argv[1:3]] or [date.today()]
    except ValueError:
        sys.exit(__doc__.strip())
    start, end = days[0], days[-1]
    if start > end:
        sys.exit(f"FROM ({start}) is after TO ({end})")
    return start.isoformat(), end.isoformat()


def pmset_days():
    """Per day: first display-on, and the first real sleep after the last display-on."""
    out = subprocess.run(["pmset", "-g", "log"], capture_output=True, text=True).stdout
    days, first_day = {}, None
    for line in out.splitlines():
        m = PMSET_LINE.match(line)
        if not m:
            continue
        d, t, kind, msg = m.groups()
        first_day = first_day or d
        day = days.setdefault(d, {"on": None, "last_on": None, "sleep": None})
        if "Display is turned on" in msg:
            day["on"] = day["on"] or t
            day["last_on"], day["sleep"] = t, None
        elif kind == "Sleep" and "Entering Sleep state" in msg and not SELF_WAKE_SLEEP.search(msg):
            if day["last_on"] and not day["sleep"]:
                day["sleep"] = t
    return {d: v for d, v in days.items() if v["on"]}, first_day


def app_usage_days(start, end):
    if not KNOWLEDGE_DB.exists():
        return {}, None
    local = f"{MAC_EPOCH_OFFSET}, 'unixepoch', 'localtime'"
    try:
        con = sqlite3.connect(f"file:{KNOWLEDGE_DB}?mode=ro", uri=True)
        rows = con.execute(
            f"""SELECT date(ZSTARTDATE + {local}) AS d,
                       time(min(ZSTARTDATE) + {local}), time(max(ZENDDATE) + {local})
                FROM ZOBJECT WHERE ZSTREAMNAME = '/app/usage'
                  AND date(ZSTARTDATE + {local}) BETWEEN ? AND ?
                GROUP BY d""",
        (start, end),
        ).fetchall()
        first_day = con.execute(
            f"SELECT date(min(ZSTARTDATE) + {local}) FROM ZOBJECT WHERE ZSTREAMNAME = '/app/usage'"
        ).fetchone()[0]
    except sqlite3.Error as e:
        print(f"# knowledgeC unreadable ({e}); grant Full Disk Access to use it", file=sys.stderr)
        return {}, None
    return {d: (first, last) for d, first, last in rows}, first_day


def main():
    start, end = parse_args(sys.argv)
    pm, pm_from = pmset_days()
    app, app_from = app_usage_days(start, end)
    print(f"# coverage: pmset from {pm_from}, knowledgeC from {app_from}", file=sys.stderr)

    days = sorted(d for d in set(pm) | set(app) if start <= d <= end)
    if not days:
        print(f"# no activity recorded between {start} and {end}", file=sys.stderr)
    print("date\tweekday\tstart\tend\tsource\tnote")
    for d in days:
        p, a = pm.get(d), app.get(d)
        if p:
            s, e, src = p["on"], p["sleep"], "pmset"
            if a and (a[0] < s or e is None or a[1] > e):
                s, e, src = min(s, a[0]), max(e or a[1], a[1]), "pmset+knowledgeC"
        else:
            s, e, src = a[0], a[1], "knowledgeC"
        notes = []
        if (not p or d == pm_from) and (not a or d == app_from):
            notes.append("partial: oldest day in log, start may be later than actual")
        if p and not p["sleep"] and d == date.today().isoformat():
            notes.append("not slept yet; end is the last activity so far")
        weekday = datetime.strptime(d, "%Y-%m-%d").strftime("%a")
        print(f"{d}\t{weekday}\t{s}\t{e or '-'}\t{src}\t{'; '.join(notes)}")


if __name__ == "__main__":
    main()
