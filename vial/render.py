#!/usr/bin/env python3
"""Render a Cornix Vial keymap (.vil) as a standalone HTML page.

Usage: python3 vial/render.py [vial/cornix.vil] > keymap.html

Symbols are labelled as macOS interprets them with an ANSI (US) layout.
"""
import html
import json
import re
import sys
from pathlib import Path

# unshifted, shifted (US ANSI)
SHIFT_PAIRS = {
    "KC_GRAVE": ("`", "~"), "KC_1": ("1", "!"), "KC_2": ("2", "@"), "KC_3": ("3", "#"),
    "KC_4": ("4", "$"), "KC_5": ("5", "%"), "KC_6": ("6", "^"), "KC_7": ("7", "&"),
    "KC_8": ("8", "*"), "KC_9": ("9", "("), "KC_0": ("0", ")"), "KC_MINUS": ("-", "_"),
    "KC_EQUAL": ("=", "+"), "KC_LBRACKET": ("[", "{"), "KC_RBRACKET": ("]", "}"),
    "KC_BSLASH": ("\\", "|"), "KC_SCOLON": (";", ":"), "KC_QUOTE": ("'", '"'),
    "KC_COMMA": (",", "<"), "KC_DOT": (".", ">"), "KC_SLASH": ("/", "?"),
}
NAMED = {
    "KC_TAB": "Tab", "KC_LCTRL": "Ctrl", "KC_RCTRL": "Ctrl", "KC_LSHIFT": "Shift", "KC_RSHIFT": "Shift",
    "KC_CAPSLOCK": "Caps", "KC_LALT": "Opt", "KC_RALT": "Opt", "KC_LGUI": "Cmd", "KC_RGUI": "Cmd",
    "KC_SPACE": "Space", "KC_ESCAPE": "Esc", "KC_BSPACE": "BS", "KC_ENTER": "Enter", "KC_DELETE": "Del",
    "KC_MUTE": "Mute", "KC_BTN3": "中クリック",
}
ARROWS = {"KC_LEFT": "←", "KC_RIGHT": "→", "KC_UP": "↑", "KC_DOWN": "↓"}
SHIFT_KEYS = {"KC_LSHIFT", "KC_RSHIFT"}
SYMBOLS = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"


def label(code):
    """-> (html label, css class, produced symbol or None)"""
    if code in ("KC_NO", "KC_TRNS"):
        return ("" if code == "KC_NO" else "▽"), "none", None
    m = re.fullmatch(r"LSFT\((KC_\w+)\)", code)
    if m and m.group(1) in SHIFT_PAIRS:
        s = SHIFT_PAIRS[m.group(1)][1]
        return html.escape(s), "sym", s
    if code in SHIFT_PAIRS:
        s = SHIFT_PAIRS[code][0]
        return html.escape(s), ("num" if s.isdigit() else "sym"), (None if s.isdigit() else s)
    if m := re.fullmatch(r"KC_KP_(\d)", code):
        return m.group(1), "num", None
    if code == "KC_KP_DOT":
        return ".<small>テンキー</small>", "num", None
    if m := re.fullmatch(r"KC_([A-Z])", code):
        return m.group(1), "alpha", None
    if code in ARROWS:
        return ARROWS[code], "nav", None
    if m := re.fullmatch(r"(MO|OSL|TG|TO|TT|DF)\((\d+)\)", code):
        kind = {"MO": "押す間", "OSL": "1回"}.get(m.group(1), m.group(1))
        return f"L{m.group(2)}<small>{kind}</small>", "layer", None
    if code in NAMED:
        return NAMED[code], ("enc" if code in ("KC_MUTE", "KC_BTN3") else "mod"), None
    return html.escape(code.removeprefix("KC_")), "mod", None


def halves(layer):
    """Physical order: left rows as-is, right rows reversed so the outer column is on the right.
    Column 6 is the encoder slot (-1 when absent). Yields (side, row, col, code)."""
    for r in range(4):
        for c, code in enumerate(layer[r]):
            yield "L", r, c, code
        right = layer[r + 4]
        yield "R", r, 0, right[6]
        for c, code in enumerate(reversed(right[:6]), start=1):
            yield "R", r, c, code


def main():
    path = Path(sys.argv[1] if len(sys.argv) > 1 else Path(__file__).with_name("cornix.vil"))
    layers = json.loads(path.read_text())["layout"]
    used = [i for i, l in enumerate(layers)
            if i == 0 or any(k not in (-1, "KC_NO", "KC_TRNS") for row in l for k in row[:6])]

    base = {(s, r, c): code for s, r, c, code in halves(layers[0])}

    def pos_name(side, r, c):
        lab, cls, _ = label(base[(side, r, c)])
        if cls in ("alpha", "sym") and r < 3:
            return html.unescape(lab)
        return f"{'左' if side == 'L' else '右'}{'親指' if r == 3 else f'{r + 1}段'}{c if side == 'R' else c + 1}"

    access = {}
    for s, r, c, code in halves(layers[0]):
        if m := re.fullmatch(r"(MO|OSL|TG|TO|TT)\((\d+)\)", str(code)):
            kind = {"MO": "押す間", "OSL": "1回"}.get(m.group(1), m.group(1))
            access.setdefault(int(m.group(2)), []).append(f"{'左' if s == 'L' else '右'}手 {kind}")

    ways = {s: [] for s in SYMBOLS}
    base_has_shift = any(k in SHIFT_KEYS for row in layers[0] for k in row)
    for i in used:
        has_shift = any(k in SHIFT_KEYS for row in layers[i] for k in row)
        where = "ベース" if i == 0 else f'<span class="pill">L{i}</span>'
        for s, r, c, code in halves(layers[i]):
            if code == -1:
                continue
            _, _, sym = label(code)
            if sym is None and code not in SHIFT_PAIRS:
                continue
            p = html.escape(pos_name(s, r, c))
            if sym:
                ways[sym].append(f"{where} {p}" + ("" if i == 0 else " の位置"))
            if code in SHIFT_PAIRS:
                shifted = SHIFT_PAIRS[code][1]
                if has_shift:
                    ways[shifted].append(f"{where} Shift + {p}" + ("" if i == 0 else " の位置"))
                elif base_has_shift:
                    ways[shifted].append(f"ベースで Shift を押したまま {where} {p} の位置")

    out = []
    for i in used:
        how = "ベース" if i == 0 else ("／".join(access.get(i, [])) or "ベースから入る手段なし")
        cells = {"L": [], "R": []}
        for s, _, _, code in halves(layers[i]):
            if code == -1:
                cells[s].append('<div class="k gap"></div>')
            else:
                lab, cls, _ = label(code)
                cells[s].append(f'<div class="k {cls}" title="{html.escape(code)}">{lab}</div>')
        out.append(
            f'<section class="layer"><h2>Layer {i}<span class="how">{html.escape(how)}</span></h2>'
            f'<div class="scroll"><div class="board"><div class="half">{"".join(cells["L"])}</div>'
            f'<div class="half">{"".join(cells["R"])}</div></div></div></section>')

    rows = []
    for s in SYMBOLS:
        if ways[s]:
            rows.append(f'<tr><td class="s">{html.escape(s)}</td><td>{" ／ ".join(ways[s])}</td></tr>')
        else:
            rows.append(f'<tr><td class="s">{html.escape(s)}</td><td class="miss"><span class="pill warn">未割当</span></td></tr>')

    sys.stdout.write(TEMPLATE.replace("{{SOURCE}}", html.escape(path.name))
                     .replace("{{LAYERS}}", "\n".join(out)).replace("{{SYMBOLS}}", "\n".join(rows)))


TEMPLATE = """<!doctype html>
<html lang="ja"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Cornix キーマップ</title>
<style>
:root {
  --bg: #f3f4f7; --surface: #ffffff; --fg: #1d2030; --muted: #6a6f85; --line: #d8dbe5;
  --key: #ffffff; --key-none: #eceef3; --key-none-fg: #b4b8c6;
  --sym: #d9480f; --sym-bg: #fff0e6; --layer: #5b4ec7; --layer-bg: #eeebff;
  --mod: #3b4257; --mod-bg: #e4e7ef; --num: #1f7a5a; --num-bg: #e5f5ee; --nav: #1c6bb0; --nav-bg: #e5f0fb;
  --f-body: "Hiragino Sans", system-ui, sans-serif; --f-mono: ui-monospace, Menlo, monospace;
}
@media (prefers-color-scheme: dark) { :root {
  --bg: #15161d; --surface: #1d1f29; --fg: #e6e8f0; --muted: #9096ad; --line: #2e3140;
  --key: #262936; --key-none: #1b1d26; --key-none-fg: #464a5c;
  --sym: #ff9a5c; --sym-bg: #3a2418; --layer: #a89dff; --layer-bg: #2a2547;
  --mod: #c7cbda; --mod-bg: #30333f; --num: #6fd3a8; --num-bg: #17332a; --nav: #7cb8f0; --nav-bg: #172a3e;
  color-scheme: dark } }
body { margin: 0; background: var(--bg); color: var(--fg); font-family: var(--f-body); line-height: 1.6; padding: 32px 16px 56px; }
.wrap { max-width: 1020px; margin: 0 auto; display: grid; gap: 20px; }
h1 { font-size: 1.6rem; margin: 0; }
h2 { font-size: 1.1rem; margin: 0; display: flex; gap: 10px; align-items: baseline; flex-wrap: wrap; }
.lede { color: var(--muted); margin: 4px 0 0; }
section.layer { background: var(--surface); border: 1px solid var(--line); border-radius: 12px; padding: 18px; display: grid; gap: 12px; }
.how { font-size: .82rem; color: var(--muted); font-weight: 400; }
.scroll { overflow-x: auto; }
.board { display: flex; gap: 28px; justify-content: center; min-width: 760px; }
.half { display: grid; grid-template-columns: repeat(7, 48px); grid-auto-rows: 48px; gap: 5px; }
.k { border-radius: 7px; background: var(--key); border: 1px solid var(--line); display: grid; place-items: center;
  font-family: var(--f-mono); font-size: .82rem; text-align: center; line-height: 1.1; }
.k small { display: block; font-size: .6rem; color: var(--muted); font-family: var(--f-body); }
.k.none { background: var(--key-none); color: var(--key-none-fg); border-style: dashed; }
.k.sym { background: var(--sym-bg); color: var(--sym); border-color: var(--sym); font-size: 1.15rem; font-weight: 600; }
.k.layer { background: var(--layer-bg); color: var(--layer); border-color: var(--layer); font-size: .72rem; font-weight: 600; }
.k.mod { background: var(--mod-bg); color: var(--mod); font-size: .7rem; }
.k.num { background: var(--num-bg); color: var(--num); font-weight: 600; font-size: 1rem; }
.k.nav { background: var(--nav-bg); color: var(--nav); font-size: 1.1rem; }
.k.enc { border-radius: 50%; font-size: .6rem; color: var(--muted); }
.k.gap { visibility: hidden; }
table { border-collapse: collapse; width: 100%; font-size: .9rem; }
th, td { text-align: left; padding: 7px 10px; border-bottom: 1px solid var(--line); }
th { font-size: .75rem; color: var(--muted); }
td.s { font-family: var(--f-mono); font-size: 1.15rem; color: var(--sym); font-weight: 600; width: 3em; }
.pill { display: inline-block; font-size: .72rem; padding: 1px 8px; border-radius: 99px; background: var(--layer-bg); color: var(--layer); font-weight: 600; }
.pill.warn { background: var(--sym-bg); color: var(--sym); }
</style></head><body>
<div class="wrap">
<header><h1>Cornix キーマップ</h1>
<p class="lede">{{SOURCE}} から生成。記号は macOS の ANSI（US）配列として解釈。右手側は物理位置どおり左右反転。</p></header>
{{LAYERS}}
<section class="layer"><h2>記号の出し方</h2>
<div class="scroll"><table><thead><tr><th>記号</th><th>操作</th></tr></thead><tbody>
{{SYMBOLS}}
</tbody></table></div></section>
</div></body></html>
"""

if __name__ == "__main__":
    main()
