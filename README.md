# Coffee Is For Closers

A macOS `say(1)` radio-play staging of Act One of *Glengarry Glen Ross* — Blake's "coffee is for closers" speech and the office aftermath. Each character is cast as a specific synthesized voice, with per-character speech rates and pause timings shaping the rhythm of the scene.

The whole thing is a single self-contained bash script. No dependencies beyond what ships with macOS.

## Requirements

- macOS (uses `/usr/bin/say`, built into the OS)
- A terminal and speakers

## Run it

```sh
chmod +x glengarry.sh
./glengarry.sh           # play the scene
./glengarry.sh --list    # audition the cast first
```

Ctrl-C stops playback (any in-flight speech is killed).

## Casting

| Character | Voice (`say -v`) |
|---|---|
| Announcer | Good News |
| Blake | Rocko (English (US)) |
| Shelley "The Machine" Levene | Shelley (English (US)) |
| Dave Moss | Eddy (English (US)) |
| George Aaronow | Fred |
| John Williamson | Reed (English (US)) |
| Richard Roma | Oliver (English (UK)) |
| James Lingk | Alex |
| Detective | Lee (English (US)) |
| Stage directions | Whisper |

Audition any voice on its own with `say -v "Rocko (English (US))" "Hello"`. To re-cast, edit the `voice_for` function near the top of `glengarry.sh`.

## Tuning

Per-character speech rates do most of the dramatic work before any words are chosen.

| Knob | Default | Effect |
|---|---|---|
| `RATE` | 185 wpm | Global base rate (used by characters without an override) |
| `RATE_BLAKE` | 210 wpm | Doesn't let anyone breathe |
| `RATE_LEVENE` | 165 wpm | Half-beat slower than the room |
| `RATE_AARONOW` | 145 wpm | Lost before he opens his mouth |
| `RATE_MOSS` | 180 wpm | Gravel and grievance |
| `RATE_STAGE` | 150 wpm | Atmospheric, behind a whisper |
| `LINE_PAUSE` | 0.22s | Gap between lines |
| `PRINT_ONLY` | 0 | Set to 1 to print the script without speaking |

All knobs are environment variables:

```sh
RATE=200 ./glengarry.sh                 # speed up the whole room
RATE_BLAKE=230 ./glengarry.sh           # let Blake bark faster
LINE_PAUSE=0.1 ./glengarry.sh           # tighter rhythm
PRINT_ONLY=1 ./glengarry.sh             # dry run, no audio
```

## License

The staging code in this repo is yours to do whatever with — MIT, public domain, take your pick. The dialogue is © David Mamet; this is a fan project.
