#!/usr/bin/env python3
"""
glengarry_parser.py — generate a say(1) staging from a screenplay extraction.

Auto-detects two common formats:

    SCREENPLAY (cue on its own line, indented):
                    BLAKE
              dialogue here.

    PLAY (cue and dialogue on the same line, separated by colon):
        BLAKE: dialogue here.

Usage
-----
    pdftotext -layout GLENGARRY-GLEN-ROSS-script.pdf glengarry.txt
    python3 glengarry_parser.py glengarry.txt > glengarry.sh
    chmod +x glengarry.sh
    ./glengarry.sh

If it can't find any cues, run with --diagnose to print the file's structural
shape (with all dialogue content masked, so no copyrighted text is exposed).
Paste that output back to debug the format.

Useful flags
------------
    --from BLAKE         Start at the first cue for this character (default: BLAKE)
    --max-cues N         Stop after N cues
    --include-action     Render screenplay action lines as stage directions
    --list-characters    List detected characters with cue counts and exit
    --diagnose           Print masked structural info to debug format issues
    --format FMT         Force format: screenplay | play | auto (default: auto)
"""

from __future__ import annotations

import argparse
import re
import shlex
import sys
from collections import Counter
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

CHARACTER_MAP: dict[str, str] = {
    "BLAKE":      "blake",
    "LEVENE":     "levene",
    "SHELLEY":    "levene",
    "MOSS":       "moss",
    "AARONOW":    "aaronow",
    "WILLIAMSON": "williamson",
}

CAST: list[tuple[str, str, str]] = [
    ("BLAKE",      "Bad News", "The closer from downtown. Brings what he is."),
    ("LEVENE",     "Grandpa",  "Shelley 'The Machine' Levene. Worn down."),
    ("MOSS",       "Ralph",    "Dave Moss. Gravel and grievance."),
    ("AARONOW",    "Whisper",  "George Aaronow. Already defeated."),
    ("WILLIAMSON", "Junior",   "John Williamson. Smug kid with the leads."),
    ("DIRECTION",  "Daniel",   "Stage directions. Detached observer."),
]

# ---------------------------------------------------------------------------
# Regex patterns
# ---------------------------------------------------------------------------

CUE_RE = re.compile(
    r"^([A-Z][A-Z'\-]*(?:\s+[A-Z][A-Z'\-]*)*)\s*(\([^)]*\))?\s*$"
)

PLAY_CUE_RE = re.compile(
    r"^\s*([A-Z][A-Z'\-]+(?:\s+[A-Z][A-Z'\-]+){0,2})\s*:\s*(.+?)\s*$"
)

SLUG_RE = re.compile(r"^(INT\.|EXT\.|FADE IN|FADE OUT|CUT TO|DISSOLVE)", re.IGNORECASE)
PAREN_LINE_RE = re.compile(r"^\([^)]*\)$")
INLINE_PAREN_RE = re.compile(r"\s*\([^)]*\)\s*")


# ---------------------------------------------------------------------------
# Format A: screenplay (cue on own line)
# ---------------------------------------------------------------------------

def parse_screenplay_format(text: str):
    blocks = re.split(r"\n\s*\n+", text)

    for block in blocks:
        stripped = [ln.strip() for ln in block.split("\n") if ln.strip()]
        if not stripped:
            continue

        first = stripped[0]

        if SLUG_RE.match(first):
            yield ("slug", " ".join(stripped))
            continue

        m = CUE_RE.match(first)
        if (
            m
            and len(first) < 40
            and len(m.group(1).split()) <= 3
            and len(stripped) >= 2
        ):
            character = m.group(1).strip()
            parts = []
            for line in stripped[1:]:
                if PAREN_LINE_RE.match(line):
                    continue
                cleaned = INLINE_PAREN_RE.sub(" ", line).strip()
                if cleaned:
                    parts.append(cleaned)
            if parts:
                yield ("cue", character, " ".join(parts))
            continue

        yield ("action", " ".join(stripped))


# ---------------------------------------------------------------------------
# Format B: play (NAME: dialogue on same line, possibly continuing)
# ---------------------------------------------------------------------------

def parse_play_format(text: str):
    current_char = None
    pending: list[str] = []

    def flush():
        nonlocal current_char, pending
        if current_char and pending:
            joined = " ".join(p.strip() for p in pending if p.strip())
            joined = INLINE_PAREN_RE.sub(" ", joined).strip()
            if joined:
                ev = ("cue", current_char, joined)
                current_char, pending = None, []
                return ev
        current_char, pending = None, []
        return None

    for raw in text.split("\n"):
        line = raw.rstrip()
        stripped = line.strip()

        if not stripped:
            ev = flush()
            if ev:
                yield ev
            continue

        if SLUG_RE.match(stripped):
            ev = flush()
            if ev:
                yield ev
            yield ("slug", stripped)
            continue

        if PAREN_LINE_RE.match(stripped):
            continue

        m = PLAY_CUE_RE.match(line)
        if m and len(m.group(1).split()) <= 3:
            ev = flush()
            if ev:
                yield ev
            current_char = m.group(1).strip()
            pending = [m.group(2)]
        elif current_char:
            pending.append(stripped)

    ev = flush()
    if ev:
        yield ev


# ---------------------------------------------------------------------------
# Auto-detect
# ---------------------------------------------------------------------------

def parse_auto(text: str):
    a = list(parse_screenplay_format(text))
    b = list(parse_play_format(text))
    cues_a = sum(1 for e in a if e[0] == "cue")
    cues_b = sum(1 for e in b if e[0] == "cue")
    if cues_b > cues_a:
        print(f"# Auto-detected play format ({cues_b} cues vs {cues_a} screenplay).", file=sys.stderr)
        return b
    print(f"# Auto-detected screenplay format ({cues_a} cues vs {cues_b} play).", file=sys.stderr)
    return a


# ---------------------------------------------------------------------------
# Diagnostic
# ---------------------------------------------------------------------------

def diagnose(text: str, max_lines: int = 80):
    lines = text.split("\n")
    total = len(lines)
    nonblank = sum(1 for ln in lines if ln.strip())

    print(f"File: {len(text):,} chars, {total:,} lines, {nonblank:,} non-blank", file=sys.stderr)

    cues_screenplay = sum(1 for e in parse_screenplay_format(text) if e[0] == "cue")
    cues_play = sum(1 for e in parse_play_format(text) if e[0] == "cue")
    print(f"Screenplay-format cues detected: {cues_screenplay}", file=sys.stderr)
    print(f"Play-format cues detected:       {cues_play}", file=sys.stderr)
    print(file=sys.stderr)
    print(f"=== First {max_lines} non-blank lines (content masked) ===", file=sys.stderr)
    print("Legend: X=uppercase, x=lowercase, digits/punctuation kept as-is.", file=sys.stderr)
    print(file=sys.stderr)

    shown = 0
    for i, line in enumerate(lines):
        if shown >= max_lines:
            break
        if not line.strip():
            continue

        indent = len(line) - len(line.lstrip())
        stripped = line.strip()
        masked = "".join(
            ("X" if c.isupper() else "x") if c.isalpha() else c
            for c in stripped
        )

        if SLUG_RE.match(stripped):
            kind = "SLUG"
        elif CUE_RE.match(stripped) and len(stripped) < 40 and len(stripped.split()) <= 3:
            kind = "CUE-S"
        elif PLAY_CUE_RE.match(line):
            kind = "CUE-P"
        else:
            kind = "—"

        print(f"L{i:5d} ind={indent:2d} len={len(stripped):3d} {kind:5s} | {masked[:90]}", file=sys.stderr)
        shown += 1


# ---------------------------------------------------------------------------
# Scene extraction
# ---------------------------------------------------------------------------

def extract_scene(events, start_character="BLAKE", max_cues=None):
    captured = []
    cue_count = 0
    started = False

    for event in events:
        kind = event[0]

        if not started:
            if kind == "cue" and event[1] == start_character:
                started = True
                captured.append(event)
                cue_count += 1
            continue

        if kind == "slug":
            break

        captured.append(event)

        if kind == "cue":
            cue_count += 1
            if max_cues and cue_count >= max_cues:
                break

    return captured


# ---------------------------------------------------------------------------
# Bash emission
# ---------------------------------------------------------------------------

def shell_escape(s: str) -> str:
    if not re.search(r'[$`\\"!]', s):
        return f'"{s}"'
    return shlex.quote(s)


def emit_script(events, out=sys.stdout, include_action=False):
    p = lambda s="": print(s, file=out)

    p("#!/usr/bin/env bash")
    p("# ==============================================================")
    p("#  GLENGARRY GLEN ROSS — say(1) staging")
    p("#  Auto-generated by glengarry_parser.py")
    p("#  Run with --list to audition the cast before the full scene.")
    p("# ==============================================================")
    p()
    p("# --- CASTING --------------------------------------------------")
    for name, voice, note in CAST:
        p(f'{name}="{voice}"   # {note}')
    p()
    p("# --- TIMING ---------------------------------------------------")
    p("RATE_DEFAULT=185")
    p("RATE_BLAKE=215")
    p("RATE_LEVENE=170")
    p("RATE_AARONOW=140")
    p("RATE_DIRECTION=165")
    p()
    p("PAUSE_SHORT=0.30")
    p("PAUSE_BEAT=0.55")
    p("PAUSE_LONG=1.10")
    p()
    p("# --- HELPERS --------------------------------------------------")
    p('blake()      { say -v "$BLAKE"      -r "$RATE_BLAKE"     "$*"; sleep "$PAUSE_SHORT"; }')
    p('levene()     { say -v "$LEVENE"     -r "$RATE_LEVENE"    "$*"; sleep "$PAUSE_BEAT";  }')
    p('moss()       { say -v "$MOSS"       -r "$RATE_DEFAULT"   "$*"; sleep "$PAUSE_BEAT";  }')
    p('aaronow()    { say -v "$AARONOW"    -r "$RATE_AARONOW"   "$*"; sleep "$PAUSE_LONG";  }')
    p('williamson() { say -v "$WILLIAMSON" -r "$RATE_DEFAULT"   "$*"; sleep "$PAUSE_SHORT"; }')
    p('direction()  { say -v "$DIRECTION"  -r "$RATE_DIRECTION" "$*"; sleep "$PAUSE_BEAT";  }')
    p('beat()       { sleep "${1:-1}"; }')
    p()
    p("# --- AUDITION MODE --------------------------------------------")
    p('if [[ "$1" == "--list" ]]; then')
    for name, _, _ in CAST:
        p(f'  say -v "${name}" "I am the voice of {name.title()}."; sleep 0.4')
    p("  exit 0")
    p("fi")
    p()
    p("# --- SCENE ----------------------------------------------------")
    p("clear")
    p()

    unknown: set[str] = set()

    for event in events:
        kind = event[0]
        if kind == "cue":
            _, character, dialogue = event
            helper = CHARACTER_MAP.get(character)
            if helper:
                p(f"{helper} {shell_escape(dialogue)}")
            else:
                unknown.add(character)
                p(f"# [UNMAPPED: {character}] {shell_escape(dialogue)}")
        elif kind == "slug":
            _, heading = event
            p(f"# === {heading} ===")
            if include_action:
                p(f"direction {shell_escape(heading)}")
        elif kind == "action" and include_action:
            _, txt = event
            p(f"direction {shell_escape(txt)}")

    p()
    p("beat 1")
    p('direction "End of scene."')

    cue_count = sum(1 for e in events if e[0] == "cue")
    print(f"# Generated {cue_count} cues.", file=sys.stderr)
    if unknown:
        names = ", ".join(sorted(unknown))
        print(f"# Unmapped characters left as comments: {names}", file=sys.stderr)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

PARSERS = {
    "screenplay": parse_screenplay_format,
    "play":       parse_play_format,
    "auto":       parse_auto,
}


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("input", help="Path to pdftotext -layout output (.txt)")
    ap.add_argument("--from", dest="start", default="BLAKE",
                    help="Character whose first cue starts the scene (default: BLAKE)")
    ap.add_argument("--max-cues", type=int, default=None)
    ap.add_argument("--include-action", action="store_true")
    ap.add_argument("--list-characters", action="store_true")
    ap.add_argument("--diagnose", action="store_true",
                    help="Print masked structural info to debug format issues")
    ap.add_argument("--format", choices=list(PARSERS), default="auto",
                    help="Force a parser format (default: auto)")
    args = ap.parse_args()

    text = Path(args.input).read_text(encoding="utf-8", errors="replace")

    if args.diagnose:
        diagnose(text)
        return

    parser_fn = PARSERS[args.format]
    events = list(parser_fn(text))

    if args.list_characters:
        counts = Counter(e[1] for e in events if e[0] == "cue")
        if not counts:
            print("(No characters detected. Try --diagnose.)", file=sys.stderr)
            return
        for name, n in counts.most_common():
            mapped = CHARACTER_MAP.get(name, "—")
            print(f"{n:5d}  {name:20s}  -> {mapped}")
        return

    scene = extract_scene(events, start_character=args.start, max_cues=args.max_cues)

    if not scene:
        print(
            f"ERROR: No cue found for character {args.start!r}.\n"
            f"  - Run with --list-characters to see what was detected.\n"
            f"  - Run with --diagnose to inspect the file's format.",
            file=sys.stderr,
        )
        sys.exit(1)

    emit_script(scene, include_action=args.include_action)


if __name__ == "__main__":
    main()
