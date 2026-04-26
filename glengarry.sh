#!/usr/bin/env bash
# ==============================================================
#  GLENGARRY GLEN ROSS — say(1) radio-play staging
#  Hand-edited from glengarry_parser.py output.
# ==============================================================
#
# Tuning (env overrides):
#   RATE=200 ./glengarry.sh            # global base rate
#   RATE_BLAKE=230 ./glengarry.sh      # per-character override
#   LINE_PAUSE=0.1 ./glengarry.sh      # gap between lines
#   PRINT_ONLY=1 ./glengarry.sh        # print script without speaking
#   ./glengarry.sh --list              # audition the cast

RATE="${RATE:-185}"
LINE_PAUSE="${LINE_PAUSE:-0.22}"
PRINT_ONLY="${PRINT_ONLY:-0}"

trap 'killall say >/dev/null 2>&1; exit 130' INT TERM

# --- VOICES ---------------------------------------------------
voice_for() {
  case "$1" in
    BLAKE)         printf '%s' "Rocko (English (US))" ;;
    LEVENE)        printf '%s' "Shelley (English (US))" ;;
    MOSS)          printf '%s' "Eddy (English (US))" ;;
    AARONOW)       printf '%s' "Fred" ;;
    WILLIAMSON)    printf '%s' "Reed (English (US))" ;;
    ROMA)          printf '%s' "Oliver (English (UK))" ;;
    LINGK)         printf '%s' "Alex" ;;
    DETECTIVE)     printf '%s' "Lee (English (US))" ;;
    MAN)           printf '%s' "Tom (English (US))" ;;
    STAGE)         printf '%s' "Whisper" ;;
    ANNOUNCER)     printf '%s' "Good News" ;;
    *)             printf '%s' "Samantha" ;;
  esac
}

# --- RATES ----------------------------------------------------
rate_for() {
  case "$1" in
    BLAKE)   printf '%s' "${RATE_BLAKE:-210}"  ;;
    LEVENE)  printf '%s' "${RATE_LEVENE:-165}" ;;
    AARONOW) printf '%s' "${RATE_AARONOW:-145}" ;;
    MOSS)    printf '%s' "${RATE_MOSS:-180}"   ;;
    STAGE)   printf '%s' "${RATE_STAGE:-150}"  ;;
    ANNOUNCER) printf '%s' "${RATE_ANNOUNCER:-160}" ;;
    *)       printf '%s' "${RATE}"             ;;
  esac
}

# --- ENGINE ---------------------------------------------------
speak() {
  local who="$1" text="$2"
  local voice rate
  voice="$(voice_for "$who")"
  rate="$(rate_for "$who")"

  printf '\n[%s / %s]\n%s\n' "$who" "$voice" "$text"

  if [ "$PRINT_ONLY" != "1" ]; then
    /usr/bin/say -v "$voice" -r "$rate" "$text"
    sleep "$LINE_PAUSE"
  fi
}

run_scene() {
  while IFS='|' read -r who text; do
    [ -z "$who" ] && continue
    case "$who" in
      '#'*)  continue ;;
      PAUSE) sleep "$text" ;;
      *)     speak "$who" "$text" ;;
    esac
  done <<'SCENE'
ANNOUNCER|Glengarry Glen Ross. Act One.
PAUSE|0.7
STAGE|A real estate office at night. Rain on the windows. Fluorescent lights. A pot of coffee judges everyone silently.
PAUSE|0.6
WILLIAMSON|Gentlemen.
PAUSE|0.5
BLAKE|Let me have your attention for a moment.
PAUSE|0.4
BLAKE|Because you're talking about, what you're talking about, bitching about that sale you shot, some son of a bitch don't want to buy land, somebody don't want what you're selling. Let's talk about something important.
PAUSE|0.3
BLAKE|Are they all here?
WILLIAMSON|All but one.
BLAKE|Well, I'm going anyway. Let's talk about something important.
PAUSE|0.6
STAGE|Levene gets up, walks to the table, starts to pour himself a cup of coffee.
PAUSE|0.5
BLAKE|Put that coffee down.
PAUSE|0.9
BLAKE|Coffee is for closers only.
PAUSE|0.7
BLAKE|You think I'm fucking with you? I am not fucking with you. I'm here from downtown. I'm here from Mitch and Murray. And I'm here on a mission of mercy.
PAUSE|0.4
BLAKE|Your name's Levene?
PAUSE|0.3
BLAKE|You call yourself a salesman, you son of a bitch?
PAUSE|0.5
STAGE|Moss gets up, starts for the door.
MOSS|I don't have to listen to this shit.
BLAKE|You certainly don't, pal. Because the good news is, you're fired.
PAUSE|0.6
BLAKE|The bad news is, you've all got just one week to regain your jobs. Starting with tonight.
PAUSE|0.4
BLAKE|Oh, have I got your attention now? Good.
PAUSE|0.3
BLAKE|Because we're having a little contest.
PAUSE|0.5
STAGE|He takes orange lead cards out of his briefcase.
BLAKE|The fellow with the highest sales by the thirtieth wins first place. First prize, a Cadillac Eldorado.
PAUSE|0.4
BLAKE|You wanna see second prize?
PAUSE|0.6
STAGE|He pulls out a cheap set of Japanese steak knives.
BLAKE|Second prize. A set of steak knives.
PAUSE|0.9
BLAKE|Third prize is, you're fired.
PAUSE|0.6
BLAKE|You get the picture? Are you laughing now?
PAUSE|0.4
BLAKE|You got people coming through that door in twenty-five minutes. You can't close the leads you're given, you can't close shit. You are shit. Hit the bricks, pal, and beat it.
PAUSE|0.9
LEVENE|The leads are weak.
PAUSE|1.2
BLAKE|The leads are weak.
PAUSE|0.6
BLAKE|The fucking leads are weak? You're weak. I've been in this business thirty years.
MOSS|What's your name?
BLAKE|Fuck you. That's my name.
PAUSE|0.6
BLAKE|You know why, mister? Because you drove a Honda to get here tonight. I drove a sixty thousand dollar BMW. That's my name.
PAUSE|0.4
BLAKE|And your name is, you're wanting. You can't play in the man's game, you can't close them. Then go home and tell your wife your troubles.
PAUSE|0.5
BLAKE|Because only one thing counts in this life. Get them to sign on the line which is dotted.
PAUSE|0.6
BLAKE|I know your war stories. I know the bullshit excuses that are your lives. What do you know? What do you know?
PAUSE|0.5
STAGE|He turns to the blackboard. Writes in chalk.
BLAKE|A. B. C.
PAUSE|0.4
BLAKE|Always. Be. Closing.
PAUSE|0.5
BLAKE|Always. Be. Closing.
PAUSE|0.6
BLAKE|A. I. D. A. Attention. Interest. Decision. Action.
PAUSE|0.4
BLAKE|Attention. Do I have your attention? Interest. Are you interested? I know you are, because it's fuck or walk. You close, or you hit the bricks. Decision. Have you made your decision for Christ. And action.
PAUSE|0.6
BLAKE|A. I. D. A.
PAUSE|0.4
BLAKE|Get out there. You've got the prospects coming in. You think they came in to get out of the rain? They're sitting out there waiting to give you their money.
PAUSE|0.4
BLAKE|You gonna take it? Are you man enough to take it?
PAUSE|0.5
BLAKE|You. Moss.
PAUSE|0.4
MOSS|You're such a hero, you're so rich, how come you're coming down here, wasting your time with such a bunch of bums?
PAUSE|0.8
STAGE|Blake holds up his wrist. A gold Rolex glints under the fluorescent lights.
BLAKE|You see this watch?
PAUSE|0.5
BLAKE|This watch cost more than your car. I made nine hundred and seventy thousand dollars last year. What did you make?
PAUSE|1.0
BLAKE|You see, pal? That's who I am. And you're nothing.
PAUSE|0.4
BLAKE|Nice guy? I don't give a shit. Good father? Fuck you. Go home to your kids.
PAUSE|0.5
BLAKE|You want to work here? Close.
PAUSE|0.6
BLAKE|You think this is abuse? You can't take this, how can you take the abuse you get on a sit?
PAUSE|0.4
BLAKE|You don't like it, you leave. I can go in there tonight, with the materials you've got, and make myself fifteen thousand dollars. Can you?
PAUSE|0.5
BLAKE|Get mad, you sons of bitches. Get mad. You know what it takes to sell real estate?
PAUSE|0.7
STAGE|He reaches into his case. He pulls out a pair of brass balls in a leather contraption. He crashes them onto the table.
PAUSE|0.7
BLAKE|It takes brass balls to sell real estate.
PAUSE|0.7
BLAKE|The money's out there. You pick it up, it's yours. You don't, I got no sympathy for you.
PAUSE|0.5
BLAKE|And you know what you'll be saying. Bunch of losers, sitting in a bar. Oh yeah, I used to be a salesman. It's a tough racket.
PAUSE|0.7
STAGE|He unrolls a poster. GLENGARRY HIGHLANDS, FLORIDA. He holds up a thick stack of fresh leads.
BLAKE|These are the new leads. These are the Glengarry leads. They cost a fortune. And to you, they're gold.
PAUSE|0.4
BLAKE|And you don't get them. Why? Because to give them to you is just throwing them away.
PAUSE|0.5
BLAKE|They're for the closers.
PAUSE|0.8
BLAKE|I won't wish you good luck. Because you wouldn't know what to do with it if you got it.
PAUSE|0.6
STAGE|He turns toward Moss as he heads for the door.
BLAKE|And to answer your question, pal. Why am I here? I came here because Mitch and Murray asked me to. They asked for a favor. I said the real favor, follow my advice and fire your fucking ass. Because a loser is a loser.
PAUSE|1.0
STAGE|Blake puts on his coat. The men sit, stunned.
PAUSE|0.8
MOSS|Bunch of nonsense. Treat people like that. The fuck is he gonna get off, mickey mouse sales promotion.
AARONOW|They don't mean it. I'm sure he didn't mean it about trimming down the sales force.
MOSS|And where the hell is Roma? Where is mister Ricky Roma, all the while we've got to sit here, eat this nonsense?
PAUSE|0.6
STAGE|Levene picks up the phone. Dials.
PAUSE|0.4
LEVENE|Hello. This is mister Levene. How is she doing? Is she awake? The doctor came by? What did he say?
PAUSE|0.5
LEVENE|Uh huh. Uh huh. Well. I can't come in tonight. I know she is. I know she is. I, I got to go out.
PAUSE|0.4
LEVENE|You tell her, when she wakes up. Tell her I got to go out.
PAUSE|0.5
WILLIAMSON|Gentlemen.
PAUSE|0.3
LEVENE|You tell her I'll call her from the road.
PAUSE|0.5
STAGE|Levene hangs up. Looks toward Williamson.
PAUSE|0.5
STAGE|Williamson tacks a new poster on the wall. Sales Incentive Promotion. A Cadillac. The steak knives. A calendar.
WILLIAMSON|You heard the man.
MOSS|And what is this in aid of?
WILLIAMSON|As of tonight.
MOSS|And what is this, excuse me?
WILLIAMSON|What it's in aid of is that Mitch and Murray.
MOSS|Fuck Mitch and Murray. I'm doing my job. I got to put up with this childishness.
WILLIAMSON|I didn't make the rules. I'm paid to run the office. You don't like the rules, Dave, there's the door.
PAUSE|0.6
STAGE|Williamson distributes lead cards.
WILLIAMSON|Two lead cards for tonight. Two lead cards tomorrow. End of the month, top salesman gets the Eldorado. Next man down the list, you know.
LEVENE|What about the good leads?
WILLIAMSON|The leads I've given you.
LEVENE|These leads are shit. They're old. I've seen this name at least.
WILLIAMSON|The leads are assigned randomly. You'll take what you've got. Now.
PAUSE|0.4
LEVENE|What about the new leads. The Glengarry leads. We've got the ad in the paper. Mitch and Murray spending money for some new leads. What about the Glengarry leads?
WILLIAMSON|I've got them. I'm gonna hold on to them. And they'll be assigned to closers.
LEVENE|Assigned to who?
WILLIAMSON|Based on the sales volume. First to Roma.
MOSS|Where is Roma? Why isn't he?
WILLIAMSON|Mister Roma has his leads.
MOSS|The Glengarry leads. The good leads.
WILLIAMSON|That's correct. The good leads. And you've got your leads. And as the hour is waning, I suggest those of you who are interested in a continuing job with this organization, get to work. Thank you for your attention.
PAUSE|0.9
STAGE|Williamson retreats into his private office.
PAUSE|0.5
MOSS|Look at this garbage. Worked over. Bullshit. I'm supposed to close this. I've had this guy before. I've been to his house twice.
AARONOW|I, I, I can't close this stuff.
PAUSE|0.4
AARONOW|Shelly, I mean, how am I supposed to. They're going to bounce me out of a job.
PAUSE|0.7
STAGE|Aaronow sits at a desk. Picks up the phone. Dials.
AARONOW|Hello, mister Palermo? I'm sorry. Mister Speece. Is this mister Robert Speece? This is George Aaronow, with Rio Rancho Properties. I spoke with your wife earlier.
PAUSE|0.4
AARONOW|I'm calling from the airport. I'm between planes. And consulting my map I see that you and your wife live near the airport. I have some, rather unusual, rather good information on the property, and I'd...
PAUSE|0.6
STAGE|Levene picks up a lead card. Bruce and Harriet Nyborg. He dials.
PAUSE|0.5
LEVENE|Hello. Hello. This is Sheldon Levene. Listen closely please. I only have a moment. I can only speak to misses Nyborg. This is misses Nyborg?
PAUSE|0.4
LEVENE|Listen closely please. I'm calling from Consolidated Properties of Arizona. Our computer picked your name at random from the thousands who write in for information on our properties.
PAUSE|0.3
LEVENE|Under the federal law, your prize, as you know, must be awarded to you whether or not you engage in our Land Investment Plan. The only stipulation is that both you and your husband must sign at the same time, for the receipt of your prize.
PAUSE|0.4
LEVENE|I'll be in the Chicago area tonight and tomorrow. Which time would be more convenient for me to speak with both you and your husband?
PAUSE|0.7
AARONOW|Well, what time would be more con. Well, no, I only have the two. But, but, yes, but I, uh, we're not, what we're talking about is investment, in. No, no, if you would.
PAUSE|0.6
STAGE|Aaronow hangs up. Walks to the front of the office. Looks out at the rain. Moss is bundling himself in his storm wear.
MOSS|Bunch of fucking nonsense, mmm?
AARONOW|I can't close them.
MOSS|Nobody can close them.
AARONOW|They're old.
MOSS|They're ancient. Bunch of nonsense. Yet some jerk to come in here.
PAUSE|0.4
AARONOW|Sometimes I just think, you know. I wonder what I'm doing in this business.
MOSS|Send a guy out there. No support. No confidence.
AARONOW|And then I say, nobody can close them. Then I look at Roma.
MOSS|Roma. Fuck Roma. He had a freak. A couple. Little run of luck. These leads are garbage.
AARONOW|Then I say, why give him the good leads. He doesn't need them.
PAUSE|0.4
MOSS|Are you going out?
AARONOW|I can't. I have to go out. I can't make a sit.
MOSS|You tried?
AARONOW|Something. There's something wrong with me. I tried both of the cards. I can't, what it is, I can't push through.
MOSS|Get your coat on. You'll come out with me.
AARONOW|Something in me.
MOSS|Forget it.
AARONOW|I try and I try, but I can't. I can't seem to.
MOSS|I said forget it. Come on.
AARONOW|I can't close them.
PAUSE|0.8
STAGE|They start out the front door. Behind them, Levene is still on the phone.
LEVENE|Well then, misses, misses Nyborg. I'll, I'll call back in. Yes. Thank you.
PAUSE|0.5
STAGE|Levene picks up another card. Dials.
PAUSE|0.5
LEVENE|Hello. Misses?
PAUSE|1.0
STAGE|The door swings closed.
PAUSE|1.4
ANNOUNCER|End of Act One.
SCENE
}

# --- AUDITION MODE -------------------------------------------
if [[ "$1" == "--list" ]]; then
  /usr/bin/say -v "Rocko (English (US))" "BLAKE. The closer from downtown. Brings what he is."
  sleep 0.5
  /usr/bin/say -v "Shelley (English (US))" "LEVENE. Shelley the Machine Levene. Worn down."
  sleep 0.5
  /usr/bin/say -v "Eddy (English (US))" "MOSS. Dave Moss. Gravel and grievance."
  sleep 0.5
  /usr/bin/say -v "Fred" "AARONOW. George Aaronow. Already defeated."
  sleep 0.5
  /usr/bin/say -v "Reed (English (US))" "WILLIAMSON. John Williamson. Smug kid with the leads."
  sleep 0.5
  /usr/bin/say -v "Oliver (English (UK))" "ROMA. Richard Roma. Top closer. Works the long con."
  sleep 0.5
  /usr/bin/say -v "Alex" "LINGK. James Lingk. Roma's mark. Already regretting it."
  sleep 0.5
  /usr/bin/say -v "Lee (English (US))" "DETECTIVE. The detective. Flat affect, taking names."
  sleep 0.5
  /usr/bin/say -v "Tom (English (US))" "MAN. Unspecified man. Background noise."
  sleep 0.5
  /usr/bin/say -v "Whisper" "STAGE. Stage directions. Atmospheric."
  sleep 0.5
  /usr/bin/say -v "Good News" "ANNOUNCER. Announcer. Sets the scene."
  sleep 0.5
  exit 0
fi

run_scene
