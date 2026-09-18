#!/usr/bin/env python3
"""Merge Claude permissions into ~/.cursor/cli-config.json.

Only permissions, approvalMode, and autoAcceptWebSearch are written.
Other live keys (authInfo, model, display) are left untouched.
Claude `ask` Bash patterns become deny because CLI has no ask prompt.
`Bash(*)` becomes `Shell(*)`.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

DOTFILES = Path(__file__).resolve().parent.parent
CLAUDE_SETTINGS = DOTFILES / "claude" / "settings.json"
LIVE_CONFIG = Path.home() / ".cursor" / "cli-config.json"

METAS = ("&&", "||", ";", "|", "`", "$(")


def convert_bash(inner: str) -> str | None:
    inner = inner.strip()
    if not inner or inner.startswith("*"):
        return None
    if any(m in inner for m in METAS):
        return None
    left, sep, right = inner.partition(":")
    use_colon = bool(sep) and not left.endswith(" ") and not right.startswith("/")
    if use_colon:
        left, args = left.strip(), right.strip()
        parts = left.split()
        cmd = parts[0]
        rest = " ".join(parts[1:])
        if rest:
            args = rest + (" *" if args in ("", "*") else " " + args)
        return f"Shell({cmd})" if not args else f"Shell({cmd}:{args})"
    parts = inner.split()
    cmd, args = parts[0], " ".join(parts[1:])
    return f"Shell({cmd})" if not args else f"Shell({cmd}:{args})"


def split_tool(raw: str) -> tuple[str, str]:
    raw = raw.strip()
    open_paren = raw.find("(")
    if open_paren < 0:
        return raw, ""
    if not raw.endswith(")"):
        return raw, ""
    return raw[:open_paren], raw[open_paren + 1 : -1]


def unique(seq: list[str]) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for item in seq:
        if item and item not in seen:
            seen.add(item)
            out.append(item)
    return out


def project(settings: dict) -> dict:
    perms = settings.get("permissions") or {}
    allow = ["Shell(*)", "Read(**)", "Write(**)", "WebFetch(*)"]
    deny: list[str] = []

    for raw in perms.get("allow") or []:
        if not raw.startswith("mcp__"):
            continue
        rest = raw[len("mcp__") :]
        if "__" not in rest:
            continue
        server, tool = rest.split("__", 1)
        allow.append(f"Mcp({server}:{tool})")

    for raw in (perms.get("deny") or []) + (perms.get("ask") or []):
        tool, inner = split_tool(raw)
        if tool.lower() == "bash":
            tok = convert_bash(inner)
            if tok:
                deny.append(tok)

    default_mode = settings.get("defaultMode") or perms.get("defaultMode")
    allow_tools = {split_tool(raw)[0] for raw in (perms.get("allow") or [])}
    return {
        "approvalMode": "auto-review" if default_mode == "auto" else "allowlist",
        "autoAcceptWebSearch": "WebSearch" in allow_tools,
        "permissions": {"allow": unique(allow), "deny": unique(deny)},
    }


def load_live(path: Path) -> dict:
    if not path.exists():
        return {"version": 1, "editor": {"vimMode": False}}
    return json.loads(path.read_text())


def write_live(path: Path, cfg: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(cfg, indent=2) + "\n"
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(payload)
    if path.is_symlink():
        path.unlink()
        tmp.replace(path)
        return
    tmp.replace(path)


def main() -> int:
    overlay = project(json.loads(CLAUDE_SETTINGS.read_text()))
    cfg = load_live(LIVE_CONFIG)
    cfg["permissions"] = overlay["permissions"]
    cfg["approvalMode"] = overlay["approvalMode"]
    cfg["autoAcceptWebSearch"] = overlay["autoAcceptWebSearch"]
    write_live(LIVE_CONFIG, cfg)
    print(f"updated {LIVE_CONFIG}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
