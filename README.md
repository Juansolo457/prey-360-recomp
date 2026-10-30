# Prey 360 Recompiled

The Xbox 360 **Prey** (2006, Human Head Studios / Venom Games, 2K Games), statically recompiled to
run natively on PC and the Steam Deck, drawn with Vulkan.

> Unofficial. **No game data included.** Bring your own Xbox 360 disc. Releases, when there are
> any, are source only: you build from your own disc.

## What it is

A **static recompilation**: the game's PowerPC code is translated to x86-64 C++ ahead of time with
[ReXGlue](https://github.com/rexglue/rexglue-sdk), and a game-specific runtime stands in for the
Xbox. Not an emulator, not a decompilation. Same approach and tooling as
[doa4-360-recomp](https://github.com/Juansolo457/doa4-360-recomp),
[lotr-conquest-360-recomp](https://github.com/Juansolo457/lotr-conquest-360-recomp),
[graw360-recomp](https://github.com/Juansolo457/graw360-recomp),
[fear360-recomp](https://github.com/Juansolo457/fear360-recomp) and
[quake4-360-recomp](https://github.com/Juansolo457/quake4-360-recomp).

The aim: the console game, its menus, its campaign and its controller feel, at any resolution,
with keyboard and mouse for desktop players where the engine kept them (the 360 build still
carries id Tech 4's `bind`, key names and mouse cvars). Xbox Live play is out of scope. Windows
first, then native Linux and the Steam Deck, both on Vulkan.

## Status

Started 2026-10-29. See [docs/HANDOFF.md](docs/HANDOFF.md) for where it stands.

- [docs/PLAN.md](docs/PLAN.md): goals, decisions, milestones, lessons from the sister projects
- [docs/HANDOFF.md](docs/HANDOFF.md): current state, how things work, where things live
- [docs/FINDINGS.md](docs/FINDINGS.md): what the disc and the executable are
- [docs/SETUP.md](docs/SETUP.md): build from your own disc

## Build (Windows)

```powershell
pwsh -NoProfile -File tools/setup.ps1                                   # toolchain, Vulkan-only SDK from source
pwsh -NoProfile -File tools/extract.ps1 -Iso 'D:\path\to\your\disc.iso' # ~4.3 GB into port/assets
pwsh -NoProfile -File tools/build.ps1                                   # translate and compile
pwsh -NoProfile -File tools/launch.ps1 -Windowed                        # run
```

The supported disc is the Redump-verified "Prey (USA, Europe) (En,Fr,De,Es,It)": `default.xex`
title `545407E0`, version 0.0.0.3.

## Layout

```
port/        the ReXGlue project: manifest, src/ (host code), assets/ (your disc, ignored)
tools/       setup, extract, build, launch, smoke, SDK patches (patches/), analysis tools
docs/        plan, setup, handoff, findings
third_party/ the patched ReXGlue source tools/setup.ps1 makes (ignored)
private/     your captures, logs and decrypted images (ignored)
```

## Contributing

Every change reaches `master` through a pull request, reviewed by CodeRabbit:
[CONTRIBUTING.md](CONTRIBUTING.md).

## Legal

- No assets, executables, generated code, keys or proprietary code are distributed. Before
  pushing, run `python -I tools/audit_repo.py`.
- Our own code is MIT ([LICENSE](LICENSE)); ReXGlue's scaffolding and our SDK patches are
  BSD-3-Clause. File by file in [NOTICE](NOTICE).
- Prey is a trademark of its owners. Not affiliated with Human Head Studios, Venom Games,
  3D Realms, 2K Games, Take-Two or Microsoft.

## Credits

- Human Head Studios and Venom Games: the game and its Xbox 360 port
- Tom Clay and contributors: [ReXGlue](https://github.com/rexglue/rexglue-sdk); the [Xenia](https://github.com/xenia-project/xenia) team
- shaunsingh: [pgr4-native](https://github.com/shaunsingh/pgr4-native), the origin of the SDK shader patches
- Built with [Claude Code](https://claude.com/claude-code)
