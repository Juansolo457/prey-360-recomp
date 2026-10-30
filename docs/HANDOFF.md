# Handoff: Prey 360 (2026-10-29)

Read [PLAN.md](PLAN.md) for the goals, decisions, milestones and the lessons from the sister
projects, and [FINDINGS.md](FINDINGS.md) for the disc and executable facts. This file is the
state, the build/run detail and where things live. Update it at the end of every session; the
next model starts here, not from chat history.

## Where it stands
**M0, M1 and the user's first target reached on the first day (2026-10-29): the logo reel, the
title screen, the main menu and New Game into the first level ("Last Call", the Roadhouse) all
draw correctly on the Vulkan backend, at a steady 30 presents a second.** Run 5 played the
opening cutscene (the letterboxed pan over the bathroom graffiti) and stood at the mirror with
Tommy's reflection correct; run 6 walked and looked around the bathroom for two minutes with
correct lighting, stencil shadows and specular. Nothing wrong seen in 138 captures. Four
manifest rounds got there (below). Next: out into the bar and the abduction (M2), then input (M3).

### Run 6 (2026-10-29, `tools/autopilot/level.txt` 240 s; log `port/logs/smoke-20261029-232052.log`)
Captures every 3 s in `private/captures/prey-level1-20261029-232052/`.
- **No crash in 240 s; 29.8 presents a second** over the whole run. The script's stick moves
  from +110 s turn and walk inside the bathroom: the stall and toilet, the "GET ME OUT OF HERE"
  graffiti, the posters, the trash can, the sinks and urinals, the fluorescent lights with
  their stencil shadows and the floor's specular all draw as on the console. The script never
  found the door (its last pitch move left the view on the floor); a better walk is next.
- Warnings: only `savedrive:\savegame.dat` (no save yet).

### Run 5 (2026-10-29, manifest round 4, `menu.txt` 180 s; log `port/logs/smoke-20261029-231549.log`)
Captures every 3 s in `private/captures/prey-menu3-20261029-231549/`.
- **No crash in 180 s.** Title at +40 s, the menus, the loading screen, then the **first level**
  from ~+95 s: the opening cutscene pans across the bathroom wall (graffiti, the poster, the
  hand dryer: letterboxed, textures and lighting right), ends at the sink; the player stands
  facing the mirror with Tommy's reflection (the mirror is a render-to-texture portal: correct).
  The script's A presses did nothing more there; the level walk is run 6's job.
- **30.0 presents a second** in every 10 s window of the level, as in the menus.
- Warnings: only `d:\d3xp\pak000.pk4` (4 probes) and `savedrive:\savegame.dat` (no save
  yet). Render targets unchanged: the 1280x2048 pair at EDRAM 0/720 and a 320x8192 pair.

### Run 4 (2026-10-29, manifest round 3, `menu.txt` 180 s; log `smoke-20261029-231242.log`)
Captures in `private/captures/prey-menu2-20261029-231242/`. The real menu shape: the title, then
**SINGLE PLAYER / MULTIPLAYER / ...**, SINGLE PLAYER opens **RESUME GAME / NEW GAME / LOAD GAME**;
the script's blind A presses took LOAD GAME, which shows "No saved games found on current storage
devices. Press A to start a new game, or B to cancel" (drawn correctly), and A started a new game:
the "Last Call" loading screen with Tommy's biography at +60 s. **Crash at +62 s** on
"Call to invalid or unregistered function at 0x824B15B8": a function entry right after a `bctr`,
with a vtable pointer at 0x8298B75C and no `.pdata` entry, a class neither finder reports. The
fix is general: **`tools/find_code_pointers.py`** (new) lists every pointer in `.rdata`/`.data`
into code that is unregistered and follows a function end: 374 (round 4), added wholesale,
none dropped (no "Unresolved" warning). `find_vcall_thunks.py` had DOA4's `.text` range
hard-coded (0x822F0000): it now carries Prey's (0x82120000); with it, still 0 (round 3's
forwarders are registered by then).

### Run 3 (2026-10-29, manifest round 2 final, `menu.txt` 120 s; log `port/logs/smoke-20261029-230953.log`)
Captures every 3 s in `private/captures/prey-menu1-20261029-230953/`.
- START at +38 s on the title screen; `XamShowDeviceSelectorUI` at +44 s (answered headless);
  `XamContentCreateEnumerator` finds no saves; the **main menu** at +53 s: NEW GAME over a blue
  portal, NORMAL SKILL / CHEROKEE SKILL below, drawn cleanly; A takes NEW GAME; the
  **"Last Call" loading screen** (Tommy's portrait, "Earth's savior doesn't want the job.",
  "Loading...") at +69 s, correct; `XamUserWriteProfileSettings` at +71 s.
- **Crash at +74 s:** "Call to invalid or unregistered function at 0x82160928", called from
  `sub_825FDC88` under `sub_825FC1F8` / `sub_826BEE88` (the level load). The address is a
  4-instruction virtual-call forwarder (`lwz r12,0(r3); lwz r11,0x210(r12); mtctr r11; bctr`)
  in a run of them after a function's `blr`, with no `.pdata` entry and vtable pointers at
  `0x8298B7A4`, `0x8298B904`, `0x8298B95C`, `0x8298B98C`, `0x8298C24C`. `find_vcall_thunks.py`
  had reported 0 forwarders: it counts a forwarder that follows registered straight-line code
  as that function's tail. A direct scan for the shape (any register pair) found 387 such
  forwarders, 291 unregistered, 42 with a vtable pointer in the image: **round 3** adds those
  42 (the 249 without any reference are this-adjusting tails or unreachable copies, as LOTR
  found). The finder should learn this case (next steps).
- Still 30 presents a second; `d:\d3xp\pak000.pk4` probed 4 times and missing (the Doom 3
  expansion path left in the engine: harmless).

### Run 2 (2026-10-29, manifest round 2 + setjmp/longjmp + frame hook, no input, 90 s; log `smoke-20261029-230701.log`)
Captures in `private/captures/prey-boot2-20261029-230701/`.
- **The whole run without a crash.** The logo reel (2K Games, 3D Realms, Human Head, the Venom
  logo at +15 s: a goggled robot head, correct), then the **title screen** "PRESS START" (the
  Earth struck by lightning, Tommy and Jen) from +40 s, static for the rest of the run.
- **30 presents a second** from the first frame (2,651 in 90 s). The 720p guest output in a
  2560x1440 window (`-Scale 2` is the launcher default; smoke runs at scale 1 in that window).
- Render targets: 1280x2048 color and depth at EDRAM 0 and 720 (the 720p frame, 1xMSAA) and a
  320x8192 pair at 720/1440.
- Kernel noise, none fatal: `default.xexp` probe, `XamNotifyCreateListener` every 5 s (the
  title screen polling for a sign-in change), `d:\d3xp\pak000.pk4` missing. No
  `XamShowSigninUI`, no fibers, no FP exception on the audio worker (Quake 4's C000008F has
  not shown; `fpscr_guard.cpp` stays unhooked, the five `mtfsf` addresses are in FINDINGS.md).
- The one "Unresolved b target 0x822F7D60 from 0x822F7E04" of round 2 came from the candidate
  0x822F7DEC, a loop body inside the function at 0x822F7D60: dropped (manifest comment).

### Run 1 (2026-10-29, scaffold manifest; log `smoke-20261029-230450.log`)
Vulkan on the RTX 4090 (an AMD iGPU is also listed), the first pipeline at +1 s, then "Call to
invalid or unregistered function at 0x822648F0" at +1.2 s, from `sub_82264678`: a method-table
entry right after a `bctr` (referenced from 0x8202AFA0), already in the finder's round-2 list.

### Build and codegen rounds (2026-10-29)
1. `prey_codegen` unknown: `port/generated/rexglue.cmake` still said `doa4` (the rename had
   skipped `generated/`);
2. **round 1, the scaffold manifest: no warning at all**, 285 files, `prey.exe` linked (the
   sister images each needed one to three leaf thunks here). Checks: 352 switches, 0 wrong;
   no vpkd3d128 hazard in 27,826 vector instructions; `find_missed_functions.py` 79 candidates;
   `find_vcall_thunks.py` 0 (wrongly, see run 3);
3. round 2 (the 79) + setjmp/longjmp + `PreyFrameMark`: one "Unresolved" (0x822F7DEC, dropped);
4. round 2 final: clean;
5. round 3 (42 forwarders): see run 4.

Repository: https://github.com/Juansolo457/prey-360-recomp, **public**, created 2026-10-29
(wiki and projects off, branches deleted on merge), the bootstrap commit on `master`. Branch
protection read back from the API after the push (2026-10-29): `audit` required and strict,
conversation resolution on, admins included, force pushes and deletion off. The first `audit`
run on `master` passed (9 s). CodeRabbit lists the repository in its dashboard (Repositories:
prey-360-recomp, Public; the GitHub App covers the whole account) and reviews pull requests
per `.coderabbit.yaml`.

## Next steps
1. **M2, playing:** a `level.txt` that finds the bathroom door (turn left from the mirror,
   walk) and reaches the bar; every capture checked for rendering bugs (the TV, the jukebox,
   Jen, the abduction sequence with its lights and portals); then the first alien level
   (`lotaa`) the same way, with the gravity and portal effects, against console footage. Saves
   (`savedrive:`). The user's own play with a real pad is the better test now that it runs.
2. **`find_vcall_thunks.py`** could go: `find_code_pointers.py` covers its case whenever the
   forwarder has a vtable pointer. Keep both until a project shows a forwarder without one.
3. **Input (M3):** gamepad is through; then keyboard and mouse. The engine's `bind`, key names
   and `in_mouse` are in the image (FINDINGS.md), the console build imports no keystroke call:
   find the event source (`Sys_GetEvent`'s translation) and whether a key path is alive; else
   the SDK's `mnk_mode` (keyboard/mouse to pad: `keybind_*` cvars, `mnk_sensitivity`) with a
   documented default set.
4. **Frame rate** later (the user): the game paces at 30 presents a second so far; measure where
   the time goes (Quake 4's predicated-tiling finding) before touching it.
5. **CodeRabbit** on the first PR; lock `master` once the bootstrap commit is up.
6. Linux (M5) after the Windows work is merged: DOA4's `tools/setup-linux.sh`, `build-deck.sh`,
   `tools/steamdeck/` are already in the tree, renamed and untested here.

## How it is built and run
```
pwsh -NoProfile -File tools/setup.ps1                     # once: toolchain + Vulkan-only SDK (~1 h)
pwsh -NoProfile -File tools/extract.ps1 -Iso 'D:\x360-recomps\Prey 2006\<the disc>.iso'
pwsh -NoProfile -File tools/build.ps1 [-Jobs 12]          # codegen when needed, then compile
pwsh -NoProfile -File tools/smoke.ps1 -Seconds 60         # boot check; its window shows on the user's screen
pwsh -NoProfile -File tools/smoke.ps1 -Seconds 180 -CaptureEvery 3 -Autopilot tools/autopilot/menu.txt
pwsh -NoProfile -File tools/launch.ps1 -Windowed          # a window on the user's screen
```
- **On this PC** `.tools/` is a junction to `../n3-360-recomp/reference/N3-Recomp/.tools` (LLVM
  20.1.8, CMake 3.31.8, Ninja 1.13.1) and `third_party/rexglue-sdk-bd833a2` is a junction to
  `../quake4-360-recomp/third_party/rexglue-sdk-bd833a2`: ReXGlue `bd833a2` with GRAW's patch
  set, Quake 4's and LOTR's `vexptefp-underflow` (tree `12884d9`, HEAD `cf0b7a0`), built
  Vulkan-only. `tools/setup.ps1` checks the tree and the install stamp `prey-sdk-tree`, written
  by hand (2026-10-29) with the same tree hash since the install was built from it; DOA4's and
  LOTR's stamps sit beside it. Anyone else runs `setup.ps1` and gets their own copy.
- `build.ps1` enters a VS 2022 DevShell, checks the XEX hash, runs `prey_codegen`, reconfigures
  once on the first run, then builds `port/out/build/win-amd64-relwithdebinfo/prey.exe`. A full
  codegen is about 8 s and 285 files; the compile a few minutes at 12 jobs.
- Builds and test runs need no OK in this repo (PLAN.md, decisions). The smoke window shows on
  the user's screen.

## Analysis tools (all read-only on the game's files)
| | |
|---|---|
| `tools/xdvdfs.py <iso> list \| extract <dir> [names]` | XDVDFS reader; `tools/extract.ps1` wraps it |
| `tools/xexinfo.py <xex>` | XEX2 headers: title, build time, entry, image size, encryption, XDK libraries |
| `..\quake4-definitive\build\xexdump\xexdump.exe <xex> private\xex\default` | the decrypted image (`default.bin`), sections and the import names |
| `tools/xex_basic_decrypt.py <xex> <out.bin>` | the same without xexdump, given the retail key (`PREY_XEX_KEY`) |
| `tools/xeximports.py <xex> <image.bin> <sdk src>` | kernel/XAM imports against the SDK's export tables |
| `tools/check_switch_tables.py <image.bin> port/generated/default [--toml out.toml]` | replays every generated `switch` against the image; rerun after every codegen |
| `tools/find_missed_functions.py <image.bin> port/generated/default` | function entries the analyser missed, as manifest lines |
| `tools/check_vector_aliasing.py port/generated/default` | the vpkd3d128 hazard; `build.ps1` runs it |
| `tools/find_code_pointers.py <image.bin> port/generated/default port/prey_manifest.toml` | **run after every codegen**: code pointers in `.rdata`/`.data` that are unregistered and follow a function end, as manifest lines (rounds 3-4's class of crash) |
| `tools/find_vcall_thunks.py <image.bin> port/generated/default private/xex/pdata_funcs.txt` | virtual-call forwarders with no function-table entry (Prey's `.text` range) |
| `tools/scan_d3d.py port/generated/default` | functions that build PM4 packets (only if a native renderer is attempted) |
| `tools/rdoc_capture.ps1 -Times 212,215` | a scripted run under RenderDoc (the `PreyFrameMark` hook at the game's VdSwap call) |
| `tools/rdoc_*.py` | run with `qrenderdoc --python` (RenderDoc 1.46 in `../graw360-recomp/private/tools/renderdoc/`) |
| `--prey_audio_dump <file>` + `tools/audio_report.py`, `tools/audio_6ch_report.py` | the audio output as raw float PCM with per-second levels, clipping, submit-rate gaps |

## Where things live
| | |
|---|---|
| `port/assets/` | the extracted disc (ignored) |
| `port/prey_manifest.toml` | function hints and hooks for the code generator: rounds 1-4, setjmp/longjmp, `PreyFrameMark` |
| `port/src/` | host code: `prey_app.h` (Vulkan plugin by name, paths, controllers), `crash_report`, `frame_timing`, `fpscr_guard` (unhooked), `autopilot`, `ui_pad`, `ui_style`, `audio_dump`, `timer_resolution`, `cpu_check` |
| `tools/patches/` | the SDK patch set `setup.ps1` applies (shared with the sister repos) and DOA4's Linux-only ones for `setup-linux.sh` |
| `tools/setup-linux.sh`, `build-linux.sh`, `build-deck.sh`, `tools/linux/`, `tools/steamdeck/` | the native Linux and Deck builds (DOA4's, renamed, untested here) |
| `tools/autopilot/` | pad scripts for `smoke.ps1 -Autopilot`: `boot.txt` (DOA4's guesses), `menu.txt` (title, START, New Game), `level.txt` (menu.txt plus a walk through the first level) |
| `private/` | local only: decrypted image, strings, `.pdata` list and `round3.txt` (`xex/`), captures, build and smoke logs |
| `docs/` | PLAN, HANDOFF (this), FINDINGS, SETUP |

## Known traps (from the sister projects; the full list is PLAN.md "Lessons applied")
- Jump tables on a 64 KB boundary and byte-indexed tables are misread by `bd833a2`; a
  halfword-index register bug too (DOA4). `check_switch_tables.py` after every codegen.
- A method right after a function's last branch has no `.pdata` entry and the analyser misses
  it (runs 1, 3, 4: a "Call to invalid or unregistered function" at a vtable's target).
  `find_code_pointers.py` lists them all from the data sections: run it before the first run.
- `longjmp` through translated code without the manifest entries corrupts the host stack.
- Renderer options only as `--name=value`.
- A pad press in a runtime dialog needs `SetNavCursorVisible(true)` (in `ui_pad.cpp` already).
- `readback_resolve` defaults to `none`; decide per feature, log the chosen value.
- The rename from a sister repo must include `port/generated/rexglue.cmake` (tracked, BSD).
