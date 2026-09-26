# Project review - September 2026

## What the app does

Letter Champ teaches tracing letters and optional digits, with English and Swedish UI. Swedish adds å, ä, and ö. Players choose uppercase, lowercase, or mixed case and alphabetic or shuffled order. Ordered checkpoints validate freehand strokes, including dots and combined segments. Successful letters award increasing streak bonuses, incorrect strokes subtract points, and hints cost points after the first free use.

The five screens are the landing menu, gameplay, animated instructions, settings, and high scores. Settings and records live locally in SharedPreferences. Background music and effects use separate singleton audio players. There is no app backend, login, or analytics integration in the reviewed source. The original app fetched fonts at runtime. Recovery bundles the exact Press Start 2P and Poppins regular fonts and disables runtime fetching to keep typography available offline.

## Code map

| Location | Responsibility |
| --- | --- |
| `lib/main.dart` | App bootstrap, theme, named routes, audio initialization |
| `lib/screens/gameplay_screen.dart` | Letter selection, scoring, hints and messages |
| `lib/screens/instruction_screen.dart` | Tutorial steps, with its own single-stroke L |
| `lib/widgets/tracing_canvas.dart` | Tracing surface: design-space scaling, gestures and painting, shared by game and tutorial |
| `lib/widgets/character_sprite.dart` | The mascot on the menu: blinks by swapping in `game_character_blink.png`, and bobs by one sprite pixel |
| `lib/models/stroke_validator.dart` | Checks traced strokes against checkpoints; joins strokes drawn in one go |
| `lib/models/game_rules.dart` | Bonus, penalty, hint cost and the streak formula |
| `lib/models/stroke_checkpoint.dart` | Ordered checkpoint model |
| `lib/data/letter_stroke_paths.dart` | Checkpoints for upper/lowercase English and Swedish letters and digits |
| `lib/data/stroke_path_tools.dart` | Authoring helper that turns a drawn stroke into evenly spaced checkpoints |
| `lib/theme/` | Palette, pixel-font text styles, retro widgets and stroke drawing |
| `lib/services/settings_service.dart` | Settings, high score, and streak persistence |
| `lib/services/music_manager.dart`, `sound_effects_manager.dart` | Music with lifecycle handling, and effects |
| `android/`, `ios/` | Native app runners |

## Initial findings and recovery

- Last existing commit: March 12, 2025. Initial working tree was clean.
- Installed baseline: Flutter 3.29.3 / Dart 3.7.2. Dependencies restored without changing the lockfile.
- Initial `flutter analyze` passed, but the only test was the unrelated generated counter test and failed. Replaced it with settings persistence/default/reset tests and tracing-data completeness/finite-coordinate checks. These do not replace gameplay widget or device tests.
- Android build initially failed because splash XML referenced untracked/missing background and branding resources. Regenerated Android splash resources from the existing configuration.
- Fixed `android:enableOnBackInvokedCallback`, which had been placed as text after the application opening tag rather than as an attribute.
- Added portable VS Code launch and extension recommendations and local development instructions.
- Created a local API 35 Android emulator and configured Flutter to use an existing standalone JDK rather than Android Studio's bundled JDK.

## Before public release

1. **Owner licensing note:** the owner reports that no licenses are needed for the existing artwork and audio. Asset provenance was not independently verified. No project-wide code license was added. The newly bundled third-party fonts include their supplied OFL notices.
2. **Credentials/history:** a limited pattern scan of tracked text across all 40 existing commits found no matches for the credential patterns checked. No credential-related filenames were found in the history filename check. This is not a comprehensive secret audit; run a dedicated history scanner before changing repository visibility and review commit metadata for information you do not want public.
3. **Offline fonts (repaired for the baseline):** the first emulator launch logged a font-download DNS failure. The exact Press Start 2P and Poppins regular binaries referenced by the locked package are now bundled, SHA-256 verified, and accompanied by their supplied notices. Runtime fetching is disabled and an offline font-loading widget test was added. Still verify a fresh offline release install and tracing alignment when upgrading fonts.
4. **Gameplay lifecycle and input:** asynchronous screen loading and score handling can call `setState` after disposal. After the last stroke, input stays enabled during the one-second completion delay even though `currentStrokeIndex` has advanced beyond the current letter's strokes. Add regression tests for leaving during async work and drawing again during completion before repairing these paths.
5. **Canvas and dots:** lowercase descenders such as g/j/p/q/y extend below the nominal 300-unit drawing height. Check compact and landscape layouts for clipping and unreachable checkpoints. Dot strokes are handled by validation, but gesture capture uses pan callbacks; verify simple taps and Swedish accents on devices.
6. **Dependencies/toolchain:** modernize Flutter and Dart together, then update packages and native Android/iOS configuration with tests between stages. The follow-up audio fix replaces the unconstrained ExoPlayer dependency with version 0.1.2 supporting hot-restart cleanup and the existing Android minimum; the remaining packages still need review. Icon generation belongs in dev tooling; review native splash usage before relocating it. Current Android versions are AGP 8.7.0, Kotlin 1.8.22, Gradle 8.10.2, and NDK 27.0.12077973. iOS declares a 12.0 deployment target and has not been built in this Windows review.
7. **Tests and CI:** add widget/integration coverage for navigation, both languages, settings, tracing acceptance/rejection, score/hint behavior, audio lifecycle, and narrow screens. Add CI after choosing the supported Flutter baseline. Verify Android release and iOS separately.
8. **Public presentation:** maintain the linked setup instructions and relative screenshot links, add contribution guidance and any applicable asset credits, and distinguish tested platforms from planned support. `publish_to: none` should remain: making the Git repository public does not require publishing the app as a pub.dev package.

## Dependency snapshot

`flutter pub outdated` on the installed baseline reported these direct package versions. These are the initial baseline observations, not a permanent upgrade prescription. The subsequent hot-restart audio fix updates audioplayers to 6.6.0 and audioplayers_android_exo to 0.1.2 in the lockfile.

| Package | Locked | Latest reported |
| --- | --- | --- |
| audioplayers | 6.3.0 | 6.8.1 |
| audioplayers_android_exo | 0.1.1 | 0.1.4 |
| shared_preferences | 2.5.2 | 2.5.5 |
| google_fonts | 6.2.1 | 8.2.1 |
| flutter_launcher_icons | 0.14.3 | 0.14.4 |
| flutter_native_splash | 2.4.5 | 2.4.8 |
| flutter_lints | 5.0.0 | 6.0.0 |
| cupertino_icons | 1.0.8 | 1.0.9 |

Many latest versions cannot resolve on the old SDK. A bulk package upgrade before establishing a device-tested baseline would make failures harder to diagnose.

## Verified baseline results

- `flutter analyze`: passed with no issues after the recovery changes.
- `flutter test`: all six tests passed, including loading both fonts with runtime fetching disabled.
- `flutter build apk --debug --target-platform android-x64`: passed using the standalone Corretto JDK, producing the emulator debug APK.
- `flutter doctor -v`: Android toolchain passed with the independent JDK.
- The final debug APK installed and launched successfully on the API 35 emulator. The landing screen was visually checked with the intended bundled font, and the new app process had no Flutter/Android startup errors in the checked log. Restarting the local ADB server resolved its initial authorization issue.
- The background emulator was stopped after verification; its saved Letterchamp_API_35 profile remains available for VS Code.
- iOS, Android release mode, physical devices, and full gameplay flows remain unverified.

## Audio restart follow-up

The original audio plugin left two native music tracks active after a hot restart. Updated the audio packages to include upstream cleanup, with ExoPlayer pinned to 0.1.2 to preserve Android API 21 support. The updated Android debug APK was built and installed on the existing emulator. Two consecutive Flutter hot restarts each left exactly one active Letterchamp audio track, with no Flutter or Android runtime errors in the checked log. Analysis and all six existing tests passed. Music volume remains at the owner's requested 100% test setting.

A later terminal attachment stalled during hot restart while the emulator and Dart VM remained responsive. Stopping the affected Flutter attach session and reopening the installed app restored playback with one active track. The cause of that debug-session stall has not been established.

## Update - September 26, 2026

Work done after the recovery, verified with `flutter analyze`, the test suite, debug and release APKs, and screenshots of every screen on the API 35 emulator:

- **Retro UI pass.** The new `lib/theme/` directory holds the palette (Sweetie 16, which matches the background art), pixel-font text styles with hard one-pixel shadows snapped to whole device pixels, and the retro widgets: flat outlined buttons, pixel icon buttons, toggles, menu-style option lists, a stepped loader and the shared background. Every screen uses them; the stock Material buttons, switches, dropdowns, icons and progress spinner are gone.
- **Text review.** Every English and Swedish string was reviewed and reworded where needed. The two Swedish errors were "Ljud Effekter" (one word) and "Första hjälpen" (which means first aid). Hint cost and stroke penalty now come from `lib/models/game_rules.dart`, so the tutorial text cannot drift from the game.
- **Layout.** The home screen no longer scrolls by the safe-area height; the character floats between the greeting and the buttons, which sit near the bottom. Settings and High Scores now account for the bottom system inset. The tutorial uses the game's layout: the letter fills the drawing area and the instruction floats in a message panel at the bottom, so the letter stays put between steps.
- **Lifecycle and input (item 4).** Async loaders and the completion delay check `mounted` before touching state, and the pan handlers ignore input while a finished letter is shown, which previously could index past the stroke list.
- **Dependencies (item 6, partly).** Packages were upgraded to the newest versions that resolve on Flutter 3.29.3, and the icon and splash generators moved to dev dependencies. Major upgrades (google_fonts 8, flutter_lints 6, audioplayers 6.8) need a newer Flutter and remain open, as does the ExoPlayer pin for API 21.
- **CI (item 7, partly).** `.github/workflows/ci.yml` runs the format check, analysis, tests and a debug APK build. Gameplay widget tests are still missing.
- **Emulator.** The quick-boot hang on the development machine was a snapshot saved from a hung instance; the development guide describes the fix.
- **Assets.** The unused `game_bg2.png` was removed and the screenshots were retaken from the current build.
- **Code quality pass.** Stroke validation, the tracing canvas and the path-authoring tool moved out of the screens into `lib/models`, `lib/widgets` and `lib/data`, removing the copies the game and tutorial each kept. The four nested attempts at matching joined strokes became one loop. Sound effects are an enum with an enabled flag on the manager, so screens no longer check the setting before every sound. The music player is `MusicManager` and no longer restarts the track when the menu re-reads settings. Screen state is private, scoring constants live in `GameRules`, and unit tests cover the validator and the bonus formula.

- **Release pipeline.** Release builds are signed with an upload key kept outside the repository (`android/key.properties`, debug fallback when absent), and a tag push runs `.github/workflows/release.yml`, which publishes the signed APK with a checksum on the Releases page. The March 2025 release and its debug-signed APK were removed; the first release of the current app takes their place.
- **License and credits.** MIT for the code, with the assets excluded; the Fesliyan Studios credit for the music in the README and in Settings.

Still open: run a dedicated secret scanner over the history (item 2), the descender and landscape checks (item 5), a newer Flutter baseline with the major package upgrades (item 6), gameplay widget tests beyond the validator and mascot (item 7), and iOS verification.
