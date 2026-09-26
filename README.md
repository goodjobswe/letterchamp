# Letter Champ

**Every stroke counts.**

Letter Champ is a Flutter game for tracing letters and numbers, with a retro look and support for English and Swedish. Follow the stroke guides, build a streak, and try to beat your personal best.

The game plays offline. Settings, high scores, and your longest streak are saved on your device; no account is required.

## Screenshots

<table>
  <tr>
    <td align="center"><img src="assets/screenshots/Screenshot_20250312_080245.jpg" alt="Letter Champ main menu with a pixel-art character and sunset background" width="240"></td>
    <td align="center"><img src="assets/screenshots/Screenshot_20250312_080318.jpg" alt="Tutorial showing the direction of the first stroke of the letter A" width="240"></td>
    <td align="center"><img src="assets/screenshots/Screenshot_20250312_080441.jpg" alt="Completed letter K with green tracing strokes and a score reward" width="240"></td>
  </tr>
  <tr>
    <td align="center">Main menu</td>
    <td align="center">Guided practice</td>
    <td align="center">Tracing and scoring</td>
  </tr>
</table>

Screenshots are from the March 2025 version. [View all screenshots](assets/screenshots).

## Features

- **Letters and numbers:** practice uppercase, lowercase, or mixed-case letters, with optional digits from 0 to 9.
- **English and Swedish:** switch the interface language and practice Swedish letters Å, Ä, and Ö.
- **Your choice of order:** work through the alphabet or shuffle the characters.
- **Stroke guidance:** learn through an animated tutorial and request hints during play.
- **Scores and streaks:** earn bonuses for consecutive correct letters and track your personal records.
- **Music and sound effects:** turn each on or off independently.

## How to play

1. Open **Settings** to choose a language, letter case, order, and whether to include numbers. The default language is English.
2. Try **Instructions** for a guided introduction, or choose **Play Now** to start tracing.
3. Draw each letter in the expected stroke order and direction. Correct letters earn points; an incorrect stroke costs 2 points and resets your streak.
4. Tap the question mark when you need a guide. The first hint in each game is free; later hints cost 5 points when you have enough points.

## Run locally

The current tested baseline is **Flutter 3.29.3 / Dart 3.7.2**. Dart is included with Flutter. Newer SDK and dependency versions are still being evaluated.

For Android, install the Flutter SDK, Android SDK tools, and a compatible Java JDK, then start an Android emulator or connect a phone with USB debugging enabled. VS Code with the Flutter extension can handle editing, running, debugging, and hot reload.

```sh
git clone https://github.com/goodjobswe/letterchamp.git
cd letterchamp
flutter doctor -v
flutter pub get
flutter devices
```

Run on the Android device listed by `flutter devices`, replacing `ANDROID_DEVICE_ID` with its ID:

```sh
flutter run -d ANDROID_DEVICE_ID
```

In VS Code, open the project folder, select your Android device, and press **F5** using the included **Letterchamp** launch configuration.

See the [development guide](docs/DEVELOPMENT.md) for emulator setup, using the Android tools without Android Studio, and iOS requirements.

## Project status

Letter Champ is being updated after a development pause. The current baseline passes static analysis and six automated tests, and the Android debug build has been launched and visually checked on an Android 15 / API 35 emulator. Full gameplay testing is still in progress.

| Platform | Status |
| --- | --- |
| Android | Debug build and startup verified on an emulator. Physical-device and release testing remain. |
| iOS | Native project included; build and runtime testing still needed on a Mac with Xcode. |
| Web and desktop | No app runners included. |

The next work covers dependency updates, gameplay lifecycle and input fixes, broader device testing, and continuous integration. The [project review](docs/PROJECT_REVIEW.md) documents the known issues and technical findings.

## Development

Run the existing checks with:

```sh
flutter analyze
flutter test
```

The tests cover settings defaults and persistence, score resets, tracing-data coverage, and loading bundled fonts without network access. They do not yet cover complete gameplay flows.

The main parts of the code are:

- `lib/screens/` — menus, settings, gameplay, and the tutorial.
- `lib/data/letter_stroke_paths.dart` — ordered tracing checkpoints for each character.
- `lib/services/` — saved settings and records, music, and sound effects.
- `android/` and `ios/` — native app projects.

For a bug report, include the device and OS, Flutter version, steps to reproduce, and the expected and actual behavior. Screenshots are helpful for layout or tracing issues.

Bundled font sources and their notices are listed in [assets/fonts](assets/fonts/README.md).
