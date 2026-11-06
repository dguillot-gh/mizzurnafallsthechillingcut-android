# Mizzurna Falls - The Chilling Cut for Android

A native Android port of **Mizzurna Falls - The Chilling Cut** (PlayStation, the Japanese release SLPS-01783 with Cirosan's English translation), made by *static recompilation*: the game's main program is translated to C and compiled for your phone ahead of time, and so is the code it loads from the disc while it plays, instead of being emulated. The rest of the console (graphics, sound, CD drive, controllers) comes from the [psxrecomp](https://github.com/mstan/psxrecomp) engine with its Android layer ([psxrecomp-android](https://github.com/dguillot-gh/psxrecomp-android)).

> **This repository contains no game data.** You build the game from your own disc: the scripts recompile it on your PC, and nothing made from it is ever committed or shared. Please do not share the builds you make (the build folder and the APK contain the game).

Part of [psx-android](https://github.com/dguillot-gh/psx-android), which lists every game.

## Status

**In progress.**

| Phone | Result |
|---|---|
| Google Pixel 8 (Tensor G3) | plays (2026-10-09, older engine) |
| LG V30 (Snapdragon 835, 2017) | boots on the 2026-11-02 build (older engine); the current engine needs a Sony BIOS backend (Known issues) |

Speed is the engine's own counter: **1.00x = full speed**. LG V30 numbers are from 2026-11-05 with the GPU renderer, the render thread and the idle skip on (this repository's defaults).

## Quick start

```
workspace\
  mizzurnafallsthechillingcut-android\     (this repository)
  discs\                  your .cue + .bin file (any names)
```

```powershell
git clone --recurse-submodules https://github.com/dguillot-gh/mizzurnafallsthechillingcut-android.git
pwsh -File mizzurnafallsthechillingcut-android\scripts\RUN-ALL.ps1 -Install
```

Make an empty folder (the *workspace*), clone into it, put your disc in `discs\` next to the clone, and run `RUN-ALL.ps1`. It gets the build tools, sets the game up from your disc, pre-compiles the disc code, builds the app and, with `-Install`, puts it on your phone over USB together with your disc. About an hour the first time; a rebuild is much faster.

Then on the phone: open **Mizzurna Falls - The Chilling Cut**, tap **Select game file**, go to **Download > mizzurnafallsthechillingcut_recomp**, pick the `.cue` file, and tap **Play**.

## What you need

- **Your own copy** of Mizzurna Falls - The Chilling Cut (serial **SLPS-01783**, the Japanese release SLPS-01783 with Cirosan's English translation), as `.cue` + `.bin`. The scripts find each disc by the SHA-1 of its data track (the first file the `.cue` names), so the file names do not matter; keep every file the `.cue` names next to it:

  | Disc | SHA-1 of the data track | Size | Files in the `.cue` |
  |---|---|---:|---:|
  | Disc 1 | `6e6156ef85c9a3bc49da8c21b7118a062e9d9d04` | 399,426,048 bytes | 1 |

- The disc is the Japanese release patched with Cirosan's English translation (*The Chilling Cut*): apply the patch to your own disc first.
- **Sony's BIOS `SCPH1001.BIN`**, dumped from your own console, in `framework\bios\` (it is never in any repository).
- **A Windows 10 or 11 PC** (64-bit) with **PowerShell 7** and **Git** (`winget install Microsoft.PowerShell`, `winget install Git.Git`), about **20 GB** free and an internet connection for the first run.
- **An Android phone**: Android 8 or newer, 64-bit ARM, OpenGL ES 3.2 for the GPU renderer, and USB debugging on (Settings > About phone > tap Build number 7 times, then Developer options > USB debugging).

## Building it, step by step

`RUN-ALL.ps1` runs these in order and stops at the first that fails. Every script takes `-DryRun` and writes a log to `logs\` in the workspace.

| Step | Script | What it does |
|---|---|---|
| 1 | `scripts\1-INSTALL-TOOLS.ps1` | Java 17, the Android SDK/NDK/CMake, Python and llvm-mingw into `tools-cache\` (asks you to accept Google's SDK licence first), the engine submodule, the recompiler. |
| 2 | `scripts\2-PREPARE.ps1` | Checks your disc by SHA-1, copies them into the workspace, sets the game up with this repository's config, recompiles the main program to C. |
| 3 | `scripts\3-PRECOMPILE.ps1` | Compiles the code the game loads from the disc for the phone (`-FromPhone` adds the code the app recorded while you played). |
| 4 | `scripts\4-BUILD-ANDROID.ps1` | Builds the app (APK) into `apks\`. |
| 5 | `scripts\5-INSTALL-PHONE.ps1` | Backs up the app's saves from the phone, installs the APK over USB, copies your disc to `Download\mizzurnafallsthechillingcut_recomp`. |

Options: `-Install`, `-Serial <id>`, `-Background <picture.jpg>`, `-AcceptAndroidLicenses` (RUN-ALL); `-Card <file.mcd>` (step 5) imports a memory card of your own. Everything stays in the workspace: nothing is installed into Windows and nothing is uploaded.

**Updating:** `git pull`, `git submodule update --init`, then `RUN-ALL.ps1 -Install` again. Saves and settings on the phone are kept; save states only load in the build that made them.

## Playing on the phone

The ≡ button at the top opens the menu: renderer (GPU or Software), resolution, aspect ratio, the FPS counter, the pad layout, 12 save-state slots, restart and quit. A Bluetooth or USB gamepad works too. The game's own memory-card saves work as on a PS1; **Import memory card** on the start screen brings in one of your own.

## Known issues

- **Needs Sony's BIOS SCPH-1001** (`game/android-bios.txt`): on the free OpenBIOS the game stops at New Game. Put your own `SCPH1001.BIN` in `framework\bios\` before step 4. The current engine also needs a BIOS *backend* generated from that dump (`framework/tools/regen_bios.sh --config bios/SCPH1001.toml`); the scripts do not do this yet, so a build from this repository boots OpenBIOS and stalls. Being worked on.

## What's next

- Generate the SCPH-1001 BIOS backend from your own BIOS dump in step 2.

## Troubleshooting

| Problem | What to do |
|---|---|
| `disc N of M not found` | Put the `.cue` and every file it names in `discs\` beside the repository, and check the data track's SHA-1 against the table above (`Get-FileHash <file.bin> -Algorithm SHA1`). |
| `no recompiler yet` | Run `scripts\1-INSTALL-TOOLS.ps1` first. |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | The app on the phone was built on another PC (another signing key): copy that PC's `tools-cache\debug.keystore` here and build again. Uninstalling also works but **deletes its saves**. |
| The phone is not found | Unlock it, allow USB debugging, check `adb devices`; with several phones pass `-Serial`. |
| A step failed | Its log is in the workspace's `logs\` folder. |

## What's in here

| Folder | What |
|---|---|
| `game/` | this game's setup: `port.ps1` (name, app id, supported discs), `game.toml`, `game.toml.in` (the app's default settings), `seeds/` (code entry points) |
| `scripts/` | the build steps |
| `tools/` | the build tools (from [psx-android](https://github.com/dguillot-gh/psx-android)) and the copyright guard |
| `template/` | the Android app template |
| `framework/` | the engine, [psxrecomp-android](https://github.com/dguillot-gh/psxrecomp-android) (submodule) |

**Never committed**: discs, saves, BIOS images, generated code, APKs, and play-capture files (they contain the game's code). `python tools/check_no_game_data.py` checks every tracked file; `--install-hook` runs it before each commit.

## Credits and licence

The engine is [psxrecomp](https://github.com/mstan/psxrecomp) by mstan with this project's Android layer; it is under the **PolyForm Noncommercial License 1.0.0**: personal, non-commercial use only. The free OpenBIOS from [PCSX-Redux](https://github.com/grumpycoders/pcsx-redux) (MIT) ships with the engine. Details in [NOTICE.md](NOTICE.md).

This repository's own files (the scripts, tools, template and game setup) are MIT ([LICENSE](LICENSE)). *Mizzurna Falls - The Chilling Cut* belongs to its publisher; this project is not affiliated with or endorsed by them or by Sony.
