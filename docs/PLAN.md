# Plan: Prey (Xbox 360), statically recompiled

Written 2026-10-29 from the user's brief and a first look at the disc. State and next steps are
in [HANDOFF.md](HANDOFF.md); disc and executable facts in [FINDINGS.md](FINDINGS.md). This file
holds the goals, the decisions, the milestones and what the earlier recomps taught that applies.

## Goal
The Xbox 360 **Prey** (Human Head Studios / Venom Games, 2K Games, 2006) running natively on
**Windows first, Linux (the Steam Deck, native, no Proton) second**, its PowerPC code translated
to x86-64 with ReXGlue and drawn with **Vulkan**. The console game as it was: its menus, its
campaign, its controller feel, at any resolution. **Gamepad first; keyboard and mouse for desktop
players as well**, because the 360 build kept id Tech 4's key bindings and mouse cvars
(FINDINGS.md). Xbox Live and system-link play are out of scope; the menus must cope with "no
connection" cleanly.

The first target (the user, 2026-10-29): **reach the main menu and start a new game without
graphical issues or artifacts.** Frame rate is adjusted later.

## Decisions (the user, 2026-10-29)
- **Vulkan is the only render API.** No D3D12 backend, option or fallback. The SDK is built from
  source with `REXGLUE_USE_D3D12=OFF` (DOAX2's recipe) and the host loads the Xenos plugin's
  Vulkan backend by name (`LoadGpuPlugin("xenos", "vulkan")`).
- **Public repository** from day one: `Juansolo457/prey-360-recomp`, source only (no builds with
  translated game code, no game files, no keys). Players build from their own disc (SETUP.md).
- **`master` is locked** like the sister repos: every change through a pull request, the `audit`
  check, an up-to-date branch, every review thread resolved, admins included. **CodeRabbit
  reviews every pull request** (`.coderabbit.yaml`).
- **Builds and test runs are allowed without asking** in this repo (the user: "you have access
  to the browser and this machine to run builds"). Never close or kill a game the user started.
- **Order: Windows + Vulkan, then Linux + Vulkan.** The native Linux/Deck build is its own
  milestone after the Windows work is reviewed and merged.
- **Use what the sister repos learned.** The template is `../doa4-360-recomp` (the newest shape,
  with the Linux build scripts); the engine knowledge is `../quake4-360-recomp` (id Tech 4 on
  the 360: the FPSCR guard, the vcall-thunk finder, the WMV intro, the 30/60 Hz pacing
  question).

## Starting points
| Source | What we take |
|---|---|
| `../doa4-360-recomp` | the repo shape: `AGENTS.md`, `CONTRIBUTING.md`, `.coderabbit.yaml`, `.github/workflows/audit.yml`, `tools/` (setup, extract, build, smoke, launch, audit, codegen checks, RenderDoc scripts, audio dump, the Linux and Deck scripts), `port/src` (app, crash reporter, FPSCR guard, frame timing, autopilot, pad bridge, timer resolution), `docs/` |
| `../quake4-360-recomp` | id Tech 4 on the 360: the audio worker's FP-exception crash and its guard, `find_vcall_thunks.py`'s origin, the 10 fps predicated-tiling finding, the emulated renderer as bring-up |
| `../lotr-conquest-360-recomp` | `readback_resolve=fast` when a game reads a resolve on the CPU, the `vexptefp` underflow patch, byte-indexed jump tables |
| `../doax2-360-recomp` | the Vulkan-only SDK build, `render_target_path_vulkan=fsi` for EDRAM-exact diagnosis, the A8-resolve and stencil patches |
| `../graw360-recomp` | the SDK patch set, the Linux/Deck container build, the native renderer if measurements ever call for it |
| `../fear360-recomp` | the most played-in port: Deck optimisation history, release checklists |
| `../quake4-360-recomp/third_party/rexglue-sdk-bd833a2` | the shared SDK checkout (junction): ReXGlue `bd833a2` + GRAW's patches + LOTR's `vexptefp-underflow`, tree `12884d9`, built Vulkan-only |

## Architecture
```
default.xex (your disc) --rexglue codegen--> port/generated/default   (C++, one function per guest function)
                                                    |
port/src        host: PreyApp (Vulkan plugin by name, paths, controllers), crash reports,
                frame timing (VdSwap hook), FPSCR guard, autopilot, pad bridge, audio dump
                                                    |
ReXGlue SDK bd833a2 + tools/patches, built from source, REXGLUE_USE_D3D12=OFF:
  runtime  (kernel/XAM, VFS over port/assets, threads, XAudio/XMA, WMV, SDL3 window, pads, keyboard/mouse)
  Xenos plugin, Vulkan backend: emulates the console GPU from the game's command buffers
```
The game is id Tech 4 with Human Head's `hh*` game code and Venom's `ven_*`/`vx*` console layer:
Venom pak archives, XACT streams, WMV videos, the engine's own sound mixer over XAudio.

## Milestones
| # | Milestone | Done when |
|---|---|---|
| M0 (done 2026-10-29) | **Repo, toolchain, first translation** | Repo on GitHub, locked, CodeRabbit on, `audit` green; the DOA4 shape copied and renamed; Vulkan-only SDK linked through the shared junction; disc extracted to `port/assets`; FINDINGS.md; codegen clean (0 wrong switch tables, no vpkd3d128 hazards, the missed-function finder at a fixed point, 0 vcall forwarders); `prey.exe` links |
| M1 | **Main menu** | The logo reel, the attract/title screen and the main menu drawn on the Vulkan backend without artifacts; a controller moves through them; sign-in and storage prompts answered; crash reporter and frame log from the first run; reference captures |
| M2 | **A new game starts** | New Game from the menu loads the first level (`roadhouse`) and plays its opening without graphical issues or artifacts; saves work; the HUD draws; a first visual-bug pass against console footage. **This is the user's first target** |
| M3 | **Input** | Gamepad complete (sticks, triggers, rumble if the SDK offers it); **keyboard and mouse** through the engine's own `bind`/`in_mouse` path if a way in exists, else the SDK's pad emulation (`mnk_mode`) with a documented binding set |
| M4 | **Windows playable** | Campaign start to finish; resolution scale; frame pacing measured and adjusted (the user: "framerate we will adjust later"); the user's play-test |
| M5 | **Native Linux and the Deck** | DOA4's Linux scripts (`setup-linux.sh`, `build-deck.sh`, the Ubuntu 22.04 container); the package in `~/recomps/Prey-360-SteamDeck/`; the user's Deck run |
| M6 | **Performance and release** | Measured bottlenecks; Release build and PGO as F.E.A.R. did; source-only release with SETUP for Windows and Linux |

Each milestone is at least one pull request. M0-M2 may share one, as the sister repos' did.

## Lessons applied (what the sister repos paid for; do these before they bite)
**Translation (M0)**
- `check_switch_tables.py` after every codegen: `bd833a2` misreads jump tables on a 64 KB
  boundary (GRAW's shader-parser crash) and oversizes byte-indexed tables (LOTR's two), and
  DOA4 found a halfword-index register bug. This image assembles shaders at run time through
  the same D3DX parser GRAW's crash was in.
- `setjmp_address`/`longjmp_address` in the manifest from M0 (libjpeg's error exit longjmps).
  Done: found by pattern from DOA4's pair.
- Add missed-function candidates wholesale, then drop any that produce an "Unresolved" codegen
  warning (it split a function). Keep landing pads inside `.pdata` functions that warn nothing.
- `check_vector_aliasing.py` every build (`build.ps1` runs it).
- Expect Quake 4's **C000008F on the audio worker** (the game's own mixer runs on an unseeded
  FP context): `port/src/fpscr_guard.cpp` and hooks at the callback's entry and the image's five
  `mtfsf` (FINDINGS.md) the moment it shows.

**First runs (M1-M2)**
- Host **fbo** render targets by default; `--render_target_path_vulkan=fsi` for A/B when a
  band, tint or EDRAM-layout artifact shows (DOAX2's red band).
- Plugin options only as `--name=value`; the space form is dropped silently.
- `readback_resolve`: `none` by default; LOTR needed `fast` for its CPU-read exposure. id Tech 4
  has no such readback that we know of, but Prey's portals and spirit-walk effects render to
  texture: watch for a feature that never changes.
- Quake 4 ran at 10 fps on the emulated renderer because of predicated tiling (EDRAM tiles at
  720p double the command processor's work). Expect the same here; measure where the time goes
  before deciding anything (the user: frame rate later).
- Harmless noise to expect: `cache:` has no device, `default.xexp` probe, devkit `d:\` paths,
  `game:\allowconsole`-style probes (Quake 4's), devkit-memory warnings.
- `ui_pad.cpp` calls `ImGui::SetNavCursorVisible(true)` on a pad press or A never confirms a
  runtime dialog.
- Shared controllers by default (a virtual XInput pad can take slot 0).
- Crash reporter, the frame counter on the game's one `VdSwap` call, autopilot scripts with
  second-stamped pad presses, a capture every N seconds, `-FreshProfile`.

**Input (M3)**
- The console build imports `XamInputGetState` only, no `XamInputGetKeystroke`, so the engine's
  key-name table is reached from the pad mapping (`ven_padButtons`) or from nothing. Find where
  `Sys_GetEvent`-style events are generated and whether a key event path is still compiled in
  (strings `bind "UPARROW" "_forward"` say the key side of the command system is). The SDK's
  `mnk_passthrough` (raw keystrokes to titles that read a USB keyboard) only helps if the game
  polls keystrokes; otherwise `mnk_mode` emulates a pad from keyboard and mouse. Prefer the
  engine's own path (real mouse look, rebindable keys) and fall back to pad emulation.

**Repo and process**
- `python -I tools/audit_repo.py` before every commit; CI runs it over every commit
  (`--history`).
- `tools/setup.ps1` checks the SDK tree hash and install stamp; on this PC `.tools/` and
  `third_party/rexglue-sdk-bd833a2` are junctions to the sister repos' copies. Any new SDK patch
  goes into `tools/patches` here **and** is committed in the shared checkout, and every sister
  repo's `setup.ps1` expected hash moves with it.
- Commit as `juansolo457 <5344231+Juansolo457@users.noreply.github.com>`.
- `HANDOFF.md` updated at the end of every session; `FINDINGS.md` keyed by the XEX hash.

## Review: CodeRabbit
- `.coderabbit.yaml` at the root (DOA4's), profile `assertive`, auto-review on `master` PRs,
  drafts off, no poem, walkthrough collapsed; path filters exclude `port/generated/**`,
  `port/assets/**`, `private/**`, `**/out/**`, `third_party/**`, `.tools/**`.
- Path instructions: `port/src/**` (guest/host boundary, Vulkan-only invariant, Linux keeps
  compiling); `port/prey_manifest.toml` (every address with its round and evidence);
  `tools/patches/**` (generic, upstreamable); `tools/**` (`python -I`, the audit guards the
  repo); `docs/**` (consistency, no promises of binaries).
- Process: fix what holds up, answer what doesn't with the reason, resolve the thread.
- The CodeRabbit GitHub App is installed on the account; a new public repo is picked up once
  it is enabled in the CodeRabbit dashboard.

## Risks
- **Pacing:** Quake 4's 360 build paced itself; Prey's `com_fixedTic`/`ven_maxLogicUpdates`
  suggest a fixed logic rate with render interpolation. Measure before touching.
- **Portals and render-to-texture:** Prey's portals, spirit walk, wall-walking and gravity
  flips stress the renderer's resolve and texture paths (the SDK's freed-page-resolve patch is
  in the tree). RenderDoc + the `rdoc_*.py` scripts are the tools.
- **Run-time shader assembly** through the image's own D3DX: the GRAW jump-table bug class.
- **Live-first menus:** the main menu's multiplayer and the sign-in nag must fail closed.
- **Keyboard and mouse** may have no event source left in the console build; then the SDK's
  pad emulation is the fallback and the milestone says so.
