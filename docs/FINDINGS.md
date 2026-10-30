# Findings: the disc and the executable

Facts about the supported disc and its `default.xex`, with how each was found. Every address is
a virtual address in the decrypted image (base `0x82000000`) of the executable below. Nothing
about where the copy came from is recorded here.

## The disc
- **Prey (USA, Europe) (En,Fr,De,Es,It)**, Redump-verified. ISO 7,834,892,288 bytes.
- Game partition at `0xFD90000`: **276 files, 4.25 GiB** (`tools/xdvdfs.py <iso> list`).
  `tools/extract.ps1` unpacks it into `port/assets` (4.3 GB on disk).
- Layout:
  - `default.xex`, the only executable (10.5 MB);
  - `Base/Paks/*.BPak0-3`: **Venom's pak archives**, four per level (`roadhouse`, `lotaa/b/d`,
    `biolabsa/b`, `feedingtowera-d`, `harvestera/b`, `shuttlea/b`, `spindlea/b`, `spherebrain`,
    `salvage`, `salvageboss`, `keeperfortress`, `superportal`, `girlfriendx`), plus `FrontEnd`,
    `LoadingKit`, `Misc`, `guis`, and `Multiplayer/` (`MPCommon` and eight `dm*` maps). The
    engine's cvars `ven_UseBinPaks`, `ven_CreateBinPaks` and the strings
    `d:\base\paks\FrontEnd.bPak0`... name them; the PC game's `.pk4` zips were repacked;
  - `Base/Stream/*.xwb`: **XACT** streaming wave banks, one per music cue (`prey_theme`,
    `prey_overture`, `roadhouse_abduction`, ...), and `test1.xgs`;
  - `Base/video/*.wmv`: **WMV** videos: `2KG`, `3DRealms`, `HHlogo`, `Venomlogo` (the logo
    reel the image names at start) and `attract.wmv` (81 MB). The image also names
    `Video\patient.wmv` and `Video\picnic.wmv`, which are not on the disc;
  - `$SystemUpdate/su20076000_00000000` (the 2006 dashboard update, unused here).

## The executable
| | |
|---|---|
| File | `default.xex`, 10,539,008 bytes |
| SHA-256 | `d1f0badecb79a1cc4765a6a833a507baf0fa7fe4c0a3032b8534a69b4028dcc6` (`tools/build.ps1` checks it) |
| Title, version | `545407E0`, **0.0.0.3**, media `1ABA0DD5`, disc 0/0 |
| Built | **2006-06-08 09:45 UTC**; original PE name `PreyFinal XENON Release.pe` |
| XDK | **2.0.2732** (June 2006): D3D9, D3DX9, XGRAPHC, XNET, XAUD, LIBCPMT, XONLINE, XHV, XAPILIB, XMEDIA, XBOXKRNL. Between DOA4's 2135 and F.E.A.R./DOAX2's 3529 |
| Image | base `0x82000000`, size `0x2170000` (35,061,760 bytes decrypted), entry `0x8230F280`, default stack 1 MB; AES-encrypted (retail key), **basic** compression (`tools/xex_basic_decrypt.py` can decrypt it; `xexdump` was used) |

Sections (`xexdump`, 2026-10-29):
| Section | Address | Size | |
|---|---|---|---|
| .rdata | `0x82000600` | `0xF6040` | |
| .pdata | `0x820F6800` | `0x1FF50` | function table, **16,362 entries** |
| .text | `0x82120000` | `0x81EB24` | 8.1 MB of code |
| .embsec_* (7) | `0x8293EC00` to `0x8295F034` | 0x9AEC, 0xA610, 0x1D5C, 0x5D90, 0x1360, 0xD0C, 0x2234 | code: embedded sections (the import thunks live in the first, `__imp__*` at 0x8293DFxx) |
| .data | `0x82960000` | `0x17C2C40` | 24.9 MB |
| .XEXID | `0x84122E00` | `0x4` | |
| .idata | `0x84130000` | `0x396` | |
| .XBLD | `0x84140000` | `0xB0` | |
| .reloc | `0x84140200` | `0x970C0` | |

### Imports (190: 133 xboxkrnl, 67 xam)
The runtime patched ten variable imports at load (`XboxKrnlVersion`, `VdGpuClockInMHz`,
`VdHSIOCalibrationLock`, `KeDebugMonitorData`, `KeCertMonitorData`, `VdGlobalDevice`,
`ExThreadObjectType`, `KeTimeStampBundle`, `ExLoadedCommandLine`, `XexExecutableModuleHandle`)
and created symbols for every function import; run 1 reached the game's code and its first draws.
Notable: `XamInputGetState`/`SetState`/`GetCapabilities` only (no `XamInputGetKeystroke`: the
console build never read a USB keyboard), `XAudioRegisterRenderDriverClient` and
`XAudioSubmitRenderDriverFrame` (the game's own mixer: expect Quake 4's FP-exception trap on the
audio worker), `XMACreateContext`, `VdSwap`, `VdInitializeEngines`, `XamShowSigninUI`,
`XamShowDeviceSelectorUI`, `XamContentCreate`, the system-link `NetDll_*` socket set, `XamVoice*`
(XHV), `XamUserCreateAchievementEnumerator`. No fiber routines are referenced and no
`ConvertThreadToFiber` string exists: no `[entrypoint.rexcrt]` needed.

### Engine and middleware (from the decrypted image's strings, 2026-10-29)
- **id Tech 4** (Doom 3's engine, as licensed for Prey): `idGameLocal`, `idSaveGame`,
  `idMultiplayerGame`, `idVertexCache`, `fs_game`, `fs_basepath`, `com_allowConsole`,
  `com_fixedTic`, `vid_restart`, `image_*` and `r_*` cvars, `default.cfg`, `preyconfig.cfg`,
  `autoexec.cfg`. Human Head's classes are `hh*` (`hhFireController`, `hhBindController`,
  `hhSpiritBowFireController`); **Venom Games'** console layer is `ven_*` cvars and `vx*` classes
  (`vxSoundCache`, `vxSoundWorld`: their own sound system over XAudio/XACT, 11025/22050/44100 Hz).
- **Keyboard and mouse survived the port:** `bind <key> [command]`, `unbind`, `unbindall`,
  `clearbind`, the default `bind "UPARROW" "_forward"` set, the full id key-name table
  (`MOUSE1`-`MOUSE5`, `KP_*`, `BACKSPACE`, `ESCAPE`, `CAPSLOCK`, `SEMICOLON`...), `in_mouse`,
  `m_pitch`, `sensitivity` ("mouse view sensitivity"), `in_freeLook`, `in_toggleCrouch`,
  `in_toggleZoom`. The pad goes through `ven_padSticks`, `ven_padButtons`, `ven_Axis*`
  (`LookPitch`, `LookYaw`, `MoveForward`, `MoveSide`, each with an `Invert`), `ven_XSensitivity`,
  `ven_YSensitivity`, `ven_MoveAccel*`, `g_VenomInputControllerID`. How key events reach the
  engine without a keystroke import is the open question of the input milestone (PLAN.md).
- **Developer paths:** `com_allowConsole`, "developer mode", `d:\base\paks\...` devkit paths
  (the disc has `Base/Paks/` under `game:`), `exec editor.cfg`, `map_localize.cfg`.
- **The Xbox 360 shader assembler and D3DX** are in the image (`vs.1.0`/`ps.1.0` diagnostics,
  `D3DX_VERSION`, the XGraphics microcode source paths from `d:\xenon\apr06\`): shaders are
  assembled at run time as in GRAW and DOAX2 (GRAW's first crash was in that parser, through a
  misread jump table).
- **libjpeg** (JFIF/Adobe marker messages): its error exit longjmps, hence setjmp/longjmp in the
  manifest from the start.
- **Xbox Live**: sessions, QoS (`XNetQos*`), voice chat ("Local Player (controller %d)
  registered with Voice chat"), achievements, marketplace UI. Multiplayer is system-link and Live
  deathmatch; out of scope.
- No Bink, Wwise, Havok or Scaleform; videos are WMV (the SDK decodes the 360's WMV, proven by
  Quake 4's intro).

### Translation facts (ReXGlue `bd833a2`, 2026-10-29)
- `.pdata` lists **16,362 functions** (0x82120000 to 0x8295CE00); the code generator
  registered **25,256** (its own analysis adds the leaves). Round 1 (the scaffold manifest)
  produced no warning at all: no `b` target outside a function, no unresolved branch. The
  sister images each needed one to three leaf thunks here.
- **setjmp** 0x822ECC00 and **longjmp** 0x822EC9B0: the MS CRT pair, found by matching DOA4's
  pair (0x82A04560 / 0x82A04220) over 24 instructions with immediates and branch targets masked,
  one hit each.
- **VdSwap** (import slot 0x8293DFA4) is called from one place, the `bl` at 0x82166170 (the
  return address 0x82166174 in the generated code): the frame hook `PreyFrameMark`.
- **mtfsf** instructions: five, at 0x822F2138, 0x822F216C, 0x822F218C, 0x822F219C (the C
  runtime's floating-point environment functions, together) and 0x822FB01C. The FPSCR guard's
  hook points if the audio worker raises C000008F (Quake 4's and DOA4's trap).
- `tools/check_switch_tables.py`: **352 switches, 0 wrong, 0 not replayed** (round 1).
- `tools/check_vector_aliasing.py`: no read-after-write hazard in 27,826 vector instructions.
- `tools/find_missed_functions.py` after round 1: **79 candidates**, added wholesale as round 2.
  One of them, 0x822648F0 (a method-table slot referenced from 0x8202AFA0; it starts right after
  a `bctr`), was the first run's "Call to invalid or unregistered function".
- `tools/find_vcall_thunks.py` (with `private/xex/pdata_funcs.txt` built from `.pdata`,
  Prey's `.text` range): 0 reported, yet run 3 died at 0x82160928, a 4-instruction forwarder
  (`lwz r12,0(r3); lwz r11,0x210(r12); mtctr r11; bctr`) in a run of them after a `blr`. A scan
  for that shape with any register pair: 387 forwarders, 291 unregistered, **42 with a vtable
  pointer** (round 3); the 249 others are this-adjusting tails or unreachable copies.
- `tools/find_code_pointers.py` (new): every pointer in `.rdata`/`.data` into code that is
  unregistered and follows a function end: **374** (round 4, none split a function). Run 4's
  crash site 0x824B15B8 (vtable pointer at 0x8298B75C) was one. 25,332 functions were
  registered before round 4.

### Input code (first look, 2026-10-29; the M3 work starts here)
- The default key binds (`bind "UPARROW" "_forward"`...) are built at 0x8267DAFC/0x8267DB08
  and 0x827FA8A8; `ven_padButtons` is registered at 0x827F4418 and 0x827F478C, `ven_padSticks`
  at 0x827F43F4, 0x827F4764 and 0x8280D938. `in_mouse` and `sensitivity` have no `lis/addi`
  reference in `.text` (reached through a cvar table in data). Where pad state becomes engine
  key/axis events, and whether a keyboard/mouse event source survived, is still to be found.
