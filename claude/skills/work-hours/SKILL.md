---
name: work-hours
description: Report the user's work start and end times (始業・終業時刻) on this Mac from its sleep/wake log and Screen Time app usage history. Use whenever the user asks when they started or finished work on some day, 何時から勤務開始したか, 何時に終業したか, 勤怠の打刻漏れ・修正申請のために時刻を知りたい, or wants daily work hours over a date range (e.g. 今月の勤務時間) — even if they don't mention logs or the Mac.
---

# Work Hours

Run the bundled script with a date or a date range (`YYYY-MM-DD`, default today):

```bash
~/.claude/skills/work-hours/scripts/work_hours.py 2026-09-28
~/.claude/skills/work-hours/scripts/work_hours.py 2026-09-01 2026-09-30
```

It prints one TSV row per day with activity (`date`, `weekday`, `start`, `end`, `source`, `note`) and, on stderr, how far back each log reaches. Present the rows as a table and relay any `note`.

## How the script decides

- **pmset -g log** (primary, about two weeks): `start` is the first time the display turned on; `end` is the first real sleep after the last display-on. Keying on display-on matters because the Mac also wakes itself for notifications and maintenance, sleeping again within seconds without lighting the screen. Counting those wakes would put `start` at 6 a.m. and turn holidays into workdays.
- **knowledgeC.db** (Screen Time, rolling 28 days): first and last foreground app use. It fills days pmset no longer covers, and extends `end` when the Mac was used after its last sleep or has not slept yet.

`source` says which log each row came from.

## What to tell the user

- These are Mac usage times, not attendance records.
- A row on a weekend or holiday, or a very short one, is probably personal use. Point it out instead of dropping it.
- A day with no row had no activity on this Mac. If that day is older than both logs (see the stderr coverage line), say it is out of range, rather than that the user did not work. Offer to fall back to their first and last Slack messages that day (`from:<@me> on:YYYY-MM-DD`).
