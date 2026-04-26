#!/usr/bin/env bash
# ==============================================================
#  GLENGARRY GLEN ROSS — say(1) staging scaffold
#
#  HOW TO USE:
#    chmod +x glengarry.sh
#    ./glengarry.sh           # play the scene
#    ./glengarry.sh --list    # audition the cast
#
#  Every line below containing [REPLACE: ...] is a placeholder.
#  Replace it with the matching beat from your own copy of the
#  script, keeping the helper function (blake / levene / etc.)
#  at the start of the line.
#
#  Or skip the manual work entirely and use glengarry_parser.py
#  to auto-generate a populated version of this file from a
#  pdftotext extraction.
# ==============================================================

# --- CASTING --------------------------------------------------
BLAKE="Bad News"      # The closer from downtown.
LEVENE="Grandpa"      # Shelley "The Machine" Levene.
MOSS="Ralph"          # Dave Moss.
AARONOW="Whisper"     # George Aaronow.
WILLIAMSON="Junior"   # John Williamson.
DIRECTION="Daniel"    # Stage directions.

# --- TIMING ---------------------------------------------------
RATE_DEFAULT=185
RATE_BLAKE=215        # Doesn't let them breathe.
RATE_LEVENE=170       # Half-beat slower. Tired.
RATE_AARONOW=140      # Slowest. Lost before he opens his mouth.
RATE_DIRECTION=165

PAUSE_SHORT=0.30
PAUSE_BEAT=0.55
PAUSE_LONG=1.10

# --- HELPERS --------------------------------------------------
blake()      { say -v "$BLAKE"      -r "$RATE_BLAKE"     "$*"; sleep "$PAUSE_SHORT"; }
levene()     { say -v "$LEVENE"     -r "$RATE_LEVENE"    "$*"; sleep "$PAUSE_BEAT";  }
moss()       { say -v "$MOSS"       -r "$RATE_DEFAULT"   "$*"; sleep "$PAUSE_BEAT";  }
aaronow()    { say -v "$AARONOW"    -r "$RATE_AARONOW"   "$*"; sleep "$PAUSE_LONG";  }
williamson() { say -v "$WILLIAMSON" -r "$RATE_DEFAULT"   "$*"; sleep "$PAUSE_SHORT"; }
direction()  { say -v "$DIRECTION"  -r "$RATE_DIRECTION" "$*"; sleep "$PAUSE_BEAT";  }
beat()       { sleep "${1:-1}"; }

# --- AUDITION MODE --------------------------------------------
if [[ "$1" == "--list" ]]; then
  say -v "$BLAKE"      "I am the voice of Blake."      ; sleep 0.4
  say -v "$LEVENE"     "I am the voice of Levene."     ; sleep 0.4
  say -v "$MOSS"       "I am the voice of Moss."       ; sleep 0.4
  say -v "$AARONOW"    "I am the voice of Aaronow."    ; sleep 0.4
  say -v "$WILLIAMSON" "I am the voice of Williamson." ; sleep 0.4
  say -v "$DIRECTION"  "I am the voice of the stage."  ; sleep 0.4
  exit 0
fi

# ==============================================================
#  SCENE — fill in the [REPLACE] markers from your script
# ==============================================================

clear
direction "A real estate office. Late evening. Rain on the windows."
beat 1

# --- BEAT 1: BLAKE ARRIVES ------------------------------------
williamson "[REPLACE: Williamson questions the stranger.]"
blake      "[REPLACE: Blake silences him; says who sent him.]"
levene     "[REPLACE: Levene asks who he is.]"
blake      "[REPLACE: Blake refuses to identify himself further.]"

# --- BEAT 2: THE COFFEE ---------------------------------------
direction "Levene reaches for a coffee cup."
blake  "[REPLACE: Blake stops him — the line about who gets coffee.]"
levene "[REPLACE: Levene defends his work.]"
blake  "[REPLACE: Blake's response about closing.]"

# --- BEAT 3: THE BOARD ----------------------------------------
direction "Blake gestures to a sales board behind him."
blake "[REPLACE: First prize.]"
beat "$PAUSE_SHORT"
blake "[REPLACE: Second prize.]"
beat "$PAUSE_SHORT"
blake "[REPLACE: Third prize.]"

# --- BEAT 4: AARONOW SPEAKS ----------------------------------
aaronow   "[REPLACE: Aaronow's complaint about the leads.]"
direction "Blake turns slowly."
blake     "[REPLACE: Blake's response.]"
aaronow   "[REPLACE: Aaronow tries to recover.]"
blake     "[REPLACE: Blake's dismissal.]"

# --- BEAT 5: ABC ----------------------------------------------
direction "Blake produces three brass letters from a briefcase."
blake "A."
beat "$PAUSE_SHORT"
blake "B."
beat "$PAUSE_SHORT"
blake "C."
beat "$PAUSE_BEAT"
blake "[REPLACE: What ABC stands for.]"

# --- BEAT 6: AIDA ---------------------------------------------
blake "[REPLACE: First word of the acronym.]"
blake "[REPLACE: Second word.]"
blake "[REPLACE: Third word.]"
blake "[REPLACE: Fourth word.]"

# --- BEAT 7: MOSS PUSHES BACK ---------------------------------
moss  "[REPLACE: Moss asks Blake's name.]"
blake "[REPLACE: Blake's status display.]"
moss  "[REPLACE: Moss's insult.]"
blake "[REPLACE: Blake's reply.]"

# --- BEAT 8: THE GLENGARRY LEADS ------------------------------
direction "Blake holds up a stack of cards bound in red string."
blake  "[REPLACE: What these leads are; who they are for.]"
levene "[REPLACE: Levene asks for one.]"
blake  "[REPLACE: The refusal.]"

# --- BEAT 9: EXIT ---------------------------------------------
direction "Blake closes his briefcase."
blake     "[REPLACE: Blake's parting line to Williamson.]"
direction "He leaves. The door closes. Rain. Silence."
beat 2

# --- AFTERMATH ------------------------------------------------
moss       "[REPLACE: Moss's first reaction.]"
levene     "[REPLACE: Levene, half to himself.]"
aaronow    "[REPLACE: Aaronow, smaller than before.]"
williamson "[REPLACE: Williamson, reasserting authority.]"

beat 1
direction "End of scene."
