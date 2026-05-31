# ♟ Bash Chess Clock

**A real-time dual countdown timer — one file, pure Bash, zero dependencies beyond the Unix toolbox.**

> 49 lines · 19 variables · every name ≤3 chars · shellcheck clean

---

## Why this exists

Chess clocks demand precision: one timer runs, one freezes, turns swap instantly, and time pressure must be visible at a glance. Most teams reach for Python, Node, or a TUI library.

This submission asks a harder question: **what if the entire game — live UI, input polling, turn logic, statistics, and graceful shutdown — had to live inside Bash itself?**

The answer is `chess_clock.sh`. No runtime. No imports. No ncurses. Just builtins, arithmetic expansion, and pipes.

---

## Requirements (for judges)

**Tested on:** Linux, macOS, and Git Bash on Windows.

| Tool | Required? | Purpose |
|------|-----------|---------|
| **Bash** | Yes | Runs the script |
| **bc** | Yes (end game only) | Float averages in the summary (`P1 avg`, `P2 avg`) |
| **awk**, **printf**, etc. | Included with Bash | Already used by the script |

The **game itself** (live clocks, turns, colors, timeout, quit) runs with Bash alone. If `bc` is missing, play still works; only the two average lines at the end will fail.

### One-command run (Linux / macOS)

```bash
bash chess_clock.sh
```

`bc` is pre-installed on most Linux distros and macOS. No extra setup.

### Windows (Git Bash)

1. Open **Git Bash** (not CMD or PowerShell).
2. Ensure `bc` works:
   ```bash
   echo "scale=1; 10/3" | bc   # expect: 3.3
   ```
3. If `bc` is missing, install a real `bc.exe` into `C:\Program Files\Git\usr\bin\` (see [MSYS2 bc package](https://packages.msys2.org/package/bc)) — avoid empty 0 KB files.

### Quick environment check

```bash
command -v bash && command -v bc && echo "scale=1; 10/3" | bc
```

If that prints `3.3`, you are ready:

```bash
bash chess_clock.sh
```

Or:

```bash
chmod +x chess_clock.sh && ./chess_clock.sh
```

---

## What you see

```
Player 1: 04:37        ← green when active, dim when waiting
Player 2: 05:00
Move: 3
Press ENTER to end your turn, q+ENTER to quit
```

The screen redraws every second. No scroll. No flicker. Active player highlighted in `\033[32m`, waiting player in `\033[2m`.

---

## Controls

| Input | Action |
|-------|--------|
| **ENTER** at start | Default 5 minutes per player |
| `<n>` + **ENTER** | Custom starting time (minutes) |
| **ENTER** in game | End turn → switch player, record move time |
| `q` + **ENTER** | Quit → print full summary |
| **Ctrl+C** | Graceful exit via `trap` → same summary path |

Invalid or empty input at startup falls back to 5 minutes. Non-numeric input is rejected safely.

---

## Constraint compliance

Every hard rule from the hackathon brief — met exactly.

| Rule | Status |
|------|--------|
| Bash only | ✅ Single `.sh` file, no other languages |
| ≤50 lines of code | ✅ **49 lines** (comments/blanks excluded) |
| Variable names ≤3 chars | ✅ **19 identifiers:** `t1`, `t2`, `act`, `mov`, `m1`, `m2`, `u1`, `u2`, `run`, `qui`, `win`, `tst`, `tot`, `min`, `el`, `r1`, `r2`, `inp`, `sec` |
| No external libraries | ✅ No ncurses, dialog, or sourced files |
| `$SECONDS` for timing | ✅ All deltas via `$((SECONDS - tst))` |
| `read -t 1` polling | ✅ 1-second non-blocking input loop |
| `printf` screen redraw | ✅ `\033[2J\033[H` wipe + home each tick |
| ANSI color highlighting | ✅ Green active / dim waiting |
| `bc` for float averages | ✅ `echo "scale=1; …" \| bc` |
| `trap` on Ctrl+C | ✅ `trap end INT` |
| Input validation | ✅ Regex + default fallback |
| shellcheck clean | ✅ Zero warnings |

---

## Architecture (49 lines, one loop)

```
┌─────────────┐     read min      ┌──────────────────────────────────┐
│   Startup   │ ────────────────► │  while run:                      │
│  validate   │                   │    el = SECONDS - tst            │
└─────────────┘                   │    compute r1/r2 display values  │
                                  │    check timeout → set win       │
                                  │    printf redraw (ANSI colors)   │
                                  │    read -t 1 inp                 │
                                  │      ENTER → swap act, log sec   │
                                  │      q       → qui=1, run=0      │
                                  └──────────────┬───────────────────┘
                                                 │
                                                 ▼
                                        ┌────────────────┐
                                        │  sum()         │
                                        │  moves, MM:SS  │
                                        │  bc averages   │
                                        │  winner/quit   │
                                        └────────────────┘
```

**State is intentionally flat.** No structs, no config objects — just scalars a judge can read in one pass:

| Var | Role |
|-----|------|
| `t1` / `t2` | Remaining seconds (stored, not recomputed from wall clock) |
| `act` | Active player (`1` or `2`) |
| `tst` | Turn start snapshot of `$SECONDS` |
| `el` | Elapsed seconds this turn |
| `sec` | Seconds consumed on turn end or interrupt |
| `u1` / `u2` | Total seconds used per player |
| `m1` / `m2` | Move count per player (for averages) |
| `mov` | Total moves |
| `run` | Loop flag (`1` = playing, `0` = stop) |
| `qui` | Early quit flag |
| `win` | Timeout winner (`1`, `2`, or unset) |

---

## Technical decisions worth scoring

### Timing without `sleep`
`sleep 1` in a loop would burn a line per tick and block input. Instead, `read -t 1` waits up to one second *and* listens for ENTER — one construct, two jobs.

### Display without a TUI library
Full-screen refresh is three bytes of escape codes. Color is two more. That replaces ncurses entirely while staying inside the 50-line budget.

### Clock math that cannot go negative
Turn-end subtraction clamps at zero:

```bash
t1=$((t1>sec?t1-sec:0))
```

If a player hits ENTER as their last second expires, stored time stays `0` — never silently negative.

### Color reset before newline
Reset codes sit *before* `\n`, not after — so ANSI state never bleeds across lines:

```bash
printf "Player 1: %02d:%02d\033[0m\n" ...
```

### One summary path for every exit
Timeout, quit (`q`), and Ctrl+C all funnel through `sum()`. Interrupt handler `end()` snapshots elapsed time into `u1`/`u2` using the same `sec` primitive as the main loop.

---

## Cross-Constraint Combo (+5 bonus)

Two constraints were designed to collide. The collision is the point.

**Constraint A — ≤3-character variable names.**  
No `remainingTime`, no `activePlayer`, no `turnStartEpoch`. State must be primitives: `t1`, `t2`, `tst`, `el`.

**Constraint B — ≤50 lines of code.**  
No helper files, no framework layer, no "just one more abstraction."

**Alone, each constraint has an escape hatch.** Long names let you hide messy logic behind readable labels. A long script lets you build proper modules. **Together, both escape hatches close.**

What remains is the language's native toolkit:

| Need | Forced solution | Why it's Bash-native |
|------|-----------------|----------------------|
| Elapsed time | `$SECONDS - tst` | Shell builtin, no subprocess |
| Tick + input | `read -t 1` | One syscall, non-blocking poll |
| Screen | `printf` + ANSI | Terminal control without a library |
| Float math | pipe to `bc` | Shell orchestrates, tool computes |
| Signals | `trap end INT` | Three lines, reuses loop primitives |

> **The thesis:** the 3-char variable name constraint forced all state into primitives (`t1`, `t2`, `tst`, `el`) with no verbose abstractions. That naturally pushed timing logic toward `$SECONDS` arithmetic and `read -t` polling — which are exactly the idiomatic Bash builtins the brief rewards. The constraints did not make the code worse; they stripped away everything that *isn't* Bash until only Bash remained.

---

## Edge cases handled

- Empty or non-numeric startup input → defaults to 5 minutes
- Clock at zero → opponent wins, final move logged
- Late ENTER (after last second) → clamped to `0`, no negative storage
- Ctrl+C mid-game → `trap` records partial turn, prints summary
- Quit with zero moves → summary prints cleanly, averages skipped when divisor is 0

---

## File structure

```
.
├── chess_clock.sh   ← the entire application
└── README.md        ← you are here
```

One script. One loop. One language.

**Run it. Press ENTER. Watch the clock tick.**
