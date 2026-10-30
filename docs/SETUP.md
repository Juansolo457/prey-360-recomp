# Build from your own disc (Windows)

This project ships **source only**. No download contains the game. The game's code is
translated from your copy of the Xbox 360 disc on your own PC, and the game data comes from the
same disc. You need your own disc of **Prey** for the Xbox 360, the USA/Europe
release (see step 3).

> Work in progress: see [HANDOFF.md](HANDOFF.md) for where it stands.

The first setup takes about an hour, most of it compiling the ReXGlue SDK. After that, rebuilds
take a few minutes.

## 1. What you need

**Hardware**
- A 64-bit CPU with AVX2 and FMA: Intel Haswell (2013) or AMD Excavator (2015) and newer.
- A GPU with a current **Vulkan 1.2** driver (NVIDIA, AMD or Intel). Vulkan is the only
  renderer.
- About 20 GB of free disk space (toolchain, SDK source and build, the extracted disc).
- An Xbox controller, plugged in before you start.

**Software**
- Windows 10 or 11, 64-bit.
- [Visual Studio 2022](https://visualstudio.microsoft.com/downloads/) with the **Desktop
  development with C++** workload. The build uses its libraries; the compiler is LLVM.
- [Git for Windows](https://git-scm.com/download/win), [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows)
  (`pwsh`) and [Python](https://www.python.org/downloads/) 3.10 or newer, on PATH.

## 2. Set up the toolchain and the SDK

```
pwsh -NoProfile -File tools/setup.ps1
```

It skips any step that is done already:
1. Downloads LLVM 20.1.8, CMake 3.31.8 and Ninja 1.13.1 into `.tools/`, each checked against
   its SHA-256.
2. Clones ReXGlue's source at nightly 0.10.0.24-dev.gbd833a2 into
   `third_party/rexglue-sdk-bd833a2` and applies `tools/patches` (code generator, renderer and
   shader translator changes from graw360-recomp and pgr4-native).
3. Builds the whole SDK with **Vulkan as the only graphics backend** and installs it into
   `third_party/rexglue-sdk-bd833a2/out/install/win-amd64`. The game links that, not ReXGlue's
   prebuilt package, which only has Direct3D 12 on Windows.

## 3. Extract your disc

```
pwsh -NoProfile -File tools/extract.ps1 -Iso "<your Prey ISO>"
```

This unpacks the game partition into `port/assets` (about 4.3 GB). The build accepts only the
USA/Europe disc's `default.xex`: title `545407E0`, version 0.0.0.3, SHA-256
`d1f0badecb79a1cc4765a6a833a507baf0fa7fe4c0a3032b8534a69b4028dcc6`. That's the Redump dump
"Prey (USA, Europe) (En,Fr,De,Es,It)".

## 4. Build

```
pwsh -NoProfile -File tools/build.ps1
```

This translates the game's code into C++ and compiles it to
`port/out/build/win-amd64-relwithdebinfo/prey.exe`. That program contains code translated from
your disc: keep it to yourself.

## 5. Run

```
pwsh -NoProfile -File tools/launch.ps1 -Windowed
```

| Option | Effect |
|---|---|
| `-Scale 1..3` | internal resolution: 1 = 1280×720 (the console's), 2 = 2560×1440 (default), 3 = 3840×2160 |
| `-Windowed` | a window instead of full screen |
| `-Trace` | every kernel call in the log |

Saves stay in `port/user`, logs in `port/logs`. A crash writes `crash-<time>.txt` next to the log.

## Linux and the Steam Deck

A native build, no Proton or Wine, drawn with the same Vulkan renderer on the host driver. The
scripts come from graw360-recomp and doax2-360-recomp. **Not yet built or run for Prey**
(branch `linux-native`, [HANDOFF.md](HANDOFF.md), "Native Linux").

1. Packages (Ubuntu names): `clang lld cmake ninja-build git python3 autoconf libgtk-3-dev
   libx11-xcb-dev libxss-dev libwayland-dev wayland-protocols libxkbcommon-dev libdecor-0-dev
   libasound2-dev libpulse-dev libpipewire-0.3-dev libvulkan-dev`. WSL2 with Ubuntu works.
2. Clone this repository on a Linux file system (a Windows checkout's CRLF line endings break the
   SDK's FFmpeg build) and put your disc's files in `port/assets` (a link to a Windows checkout's
   `port/assets` works).
3. `tools/setup-linux.sh`: the patched SDK from source, the same patched tree as Windows plus
   nine Linux-only patches, built and installed for RelWithDebInfo and Release. The
   first run takes a while.
4. `tools/build-linux.sh` (RelWithDebInfo; `--config Release` for the fast one).

A build made on a recent distribution needs that distribution's glibc, which SteamOS doesn't
have. For the Steam Deck, `tools/build-deck.sh` (needs `podman`) does steps 3 and 4 in an Ubuntu
22.04 container (`tools/linux/deck.Containerfile`, the environment ReXGlue's own Linux releases
are built in), with its own SDK checkout and build folder, and checks every binary needs glibc
2.35 at most. Then `tools/steamdeck/make_linux_package.sh --deck deck@steamdeck --with-game`
copies the Deck folder to `~/recomps/Prey-360-SteamDeck`, with your disc's files the first time.
`--deck` needs an SSH key the Deck accepts on the machine the script runs on; in WSL2 that is
WSL's own `~/.ssh`, not Windows' (`ssh-copy-id deck@steamdeck` once, with the Deck's password).
Without one the script stops at the start and says so. Otherwise copy
`private/steamdeck/Prey-360-SteamDeck` yourself, with your disc's files in its `game/`. The
folder's `README-SteamDeck-Linux.txt` says how to add it to Steam. On the Deck the game runs
at **720p by default** (`prey.toml`, `resolution_scale = 1`).
