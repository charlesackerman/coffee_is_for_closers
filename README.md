# glengarry-say

A macOS `say(1)` staging of the "Coffee Is For Closers" scene from *Glengarry Glen Ross*. Each character is cast as a specific synthesized voice; per-character speech rates and pause timings shape the rhythm of the scene.

This repo provides the staging machinery — casting, voice tuning, pacing, helper functions, and a parser that reads a `pdftotext` extraction and emits a populated bash script. The dialogue itself is not included; bring your own copy of the screenplay.

## Casting

| Character | Voice (`say -v`) | Rationale |
|---|---|---|
| Blake | Bad News | The closer from downtown. Brings what he is. |
| Shelley "The Machine" Levene | Grandpa | Old-timer, audibly worn. |
| Dave Moss | Ralph | Gravel and grievance. |
| George Aaronow | Whisper | Already defeated. |
| John Williamson | Junior | Smug office kid with the leads. |
| Stage directions | Daniel | Detached observer. |

Audition any voice with `say -v "Bad News" "Hello"`. To re-cast, edit the `CAST` and `CHARACTER_MAP` lists at the top of `glengarry_parser.py` (or the variables at the top of `glengarry.sh`).

## Two ways to use this

### A — Manual (no PDF required)

`glengarry.sh` is a runnable scaffold with `[REPLACE: ...]` markers for each beat. Edit it by hand, dropping in dialogue from your own copy of the script.

```sh
chmod +x glengarry.sh
./glengarry.sh           # play the scene
./glengarry.sh --list    # audition the cast first
```

### B — Auto-generated from a PDF

If you have a PDF of the screenplay or play, the parser will find the scene and emit a populated bash script.

```sh
brew install poppler
pdftotext -layout YOUR-COPY.pdf glengarry.txt
python3 glengarry_parser.py glengarry.txt --list-characters    # sanity check
python3 glengarry_parser.py glengarry.txt > glengarry.sh
chmod +x glengarry.sh
./glengarry.sh
```

## Parser flags

- `--from BLAKE` — character whose first cue starts the scene (default: `BLAKE`)
- `--max-cues N` — stop after N cues
- `--include-action` — render screenplay action lines as stage directions
- `--list-characters` — list detected characters with cue counts and exit
- `--diagnose` — print masked structural info (no dialogue exposed) for debugging
- `--format {auto,screenplay,play}` — force a parser format

## How the parser works

It walks the extracted text and emits three event types: `slug` (scene heading), `cue` (character + dialogue), `action` (description). Two formats are supported and auto-detected:

- **Screenplay** — character cue on its own indented line, dialogue follows on the next lines
- **Play** — `NAME: dialogue` on a single line, possibly continuing across wrapped lines

Whichever format produces more cues wins. If neither finds anything (typical when the PDF is image-based and `pdftotext` produced nothing), `--diagnose` prints the file's structural shape with all letters masked, so you can debug formatting without exposing the text.

## Tuning the performance

Per-character speech rates do most of the dramatic work before any words are chosen. The defaults:

| Knob | Default | Effect |
|---|---|---|
| `RATE_BLAKE` | 215 wpm | Doesn't let anyone breathe |
| `RATE_LEVENE` | 170 wpm | Half-beat slower than the room |
| `RATE_AARONOW` | 140 wpm | Lost before he opens his mouth |
| `RATE_DEFAULT` | 185 wpm | Moss, Williamson |
| `PAUSE_LONG` | 1.10s | Trails Aaronow's lines — the silence does the work |

Edit these at the top of the generated `glengarry.sh`.

## Troubleshooting

**"No characters detected"** — check the extraction first:

```sh
wc -l glengarry.txt
head -20 glengarry.txt
```

If the file is tiny or contains anything other than screenplay text, `pdftotext` failed silently (often: wrong path, or the PDF is in `~/Downloads` not `~`). Re-run with the explicit PDF path.

**Image-based / scanned PDF** — if `pdftotext` produces a near-empty file, the PDF has no extractable text layer. Run OCR first:

```sh
brew install ocrmypdf
ocrmypdf input.pdf input-ocr.pdf
pdftotext -layout input-ocr.pdf glengarry.txt
```

**Real text but parser still finds nothing** — run `--diagnose` and inspect the masked output. The format may be unusual: Title Case names instead of ALL CAPS, names left-aligned at column 0, names with periods (`DR.`), etc. The output uses `X` for uppercase letters and `x` for lowercase, so you can share it without sharing dialogue.

## Extending to other works

The parser is screenplay-shape-aware, not Mamet-specific. The character map and cast at the top of `glengarry_parser.py` are the only things tied to this scene. Swap them and you can stage any scene from any screenplay following standard cue conventions.

For example, to stage Moss and Aaronow's restaurant scene instead, change `--from BLAKE` to `--from MOSS` (or whichever character speaks first in your target scene) and adjust `--max-cues` to bound the length.

## Files

- `glengarry.sh` — runnable scaffold with `[REPLACE: ...]` markers
- `glengarry_parser.py` — Python parser, generates a populated `glengarry.sh` from a text extraction
- `.gitignore` — keeps extracted screenplay text and generated artifacts out of version control

## License

The staging code in this repo is yours to do whatever with — MIT, public domain, take your pick. The screenplay itself is © David Mamet and is not included in this repo.
