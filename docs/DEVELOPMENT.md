# Local development

Letterchamp currently has Android and iOS app targets. The repository does not contain web or Windows app runners.

## Baseline

The September 2026 recovery uses Flutter 3.29.3 with its bundled Dart 3.7.2 and the committed `pubspec.lock`. This establishes a reproducible baseline, not a claim that these are the latest versions. Packages were last upgraded on September 26, 2026 to the newest versions that resolve on this SDK, for example google_fonts 6.3.2. Major upgrades wait for a newer Flutter and should be done together with it in a separate tested change.

## VS Code on Windows

All Flutter/Dart editing, debugging, hot reload, and tests can be done in VS Code. Install the Flutter extension (which includes Dart support), open the repository folder, and run:

```powershell
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter emulators
```

Create an Android virtual device with Android's SDK tools if none exists. On the machine used for the recovery, `Letterchamp_API_35` is a Pixel 7 profile with the already installed Android 15 / API 35 x86_64 Google Play image. That device is local machine state and is not included in a clone of the repository.

```powershell
flutter emulators --launch Letterchamp_API_35
flutter devices
flutter run -d <android-device-id>
```

Alternatively, use **Flutter: Launch Emulator** from VS Code's command palette, select the Android device in the status bar, and press **F5** using the checked-in Letterchamp launch configuration. Hot reload is available during a debug session. A physical Android phone with USB debugging is another option.

If the emulator hangs on launch but starts fine from the **Cold Boot** entry in its menu, the quick-boot snapshot is the culprit: closing a hung emulator with save-on-exit enabled stores that hung state, and every quick boot restores it. Delete `snapshots/default_boot` inside the AVD directory, turn save-on-exit off in the emulator's snapshot settings, and give the AVD at least 4 GB of RAM for a Google Play image.

`adb` lives in `%LOCALAPPDATA%\Android\Sdk\platform-tools`. Add that directory to `PATH` or call it by its full path, for example `adb exec-out screencap -p > shot.png` to capture a screenshot.

## Android Studio is optional

Android Studio is an editor and convenient SDK/device manager; VS Code does not require that editor. Android builds still require:

- Flutter SDK, which includes Dart.
- Android SDK platforms, build tools, platform tools, command-line tools, and the required NDK.
- A Java JDK compatible with the project's Gradle version.
- Android Emulator and a system image, if using a virtual phone.

Keep the SDK directory when uninstalling Android Studio. On Windows it is commonly `%LOCALAPPDATA%\Android\Sdk`. Emulator definitions commonly live under `%USERPROFILE%\.android\avd`.

Configure an independent JDK before uninstalling Android Studio:

```powershell
flutter config --jdk-dir "C:\path\to\your\jdk"
flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"
flutter doctor -v
```

During recovery, Flutter was pointed at an existing standalone Corretto JDK 21.0.5 under the user's `.jdks` directory. This removes the dependency on Android Studio's bundled Java. That older JDK should also be updated during toolchain modernization. Do not hard-code one developer's JDK or SDK paths in the repository.

Android's `sdkmanager` and `avdmanager` command-line tools can manage packages and virtual devices without Android Studio. If invoking them directly, configure `JAVA_HOME` to the standalone JDK; Flutter's JDK setting only configures Flutter.

## Audio and hot restart

The audio dependencies require versions that dispose native players on hot restart: `audioplayers` 6.4.0 or newer and `audioplayers_android_exo` 0.1.2. The lockfile currently resolves versions 6.6.0 and 0.1.2. ExoPlayer is pinned to 0.1.2 to preserve Android API 21 support; 0.1.3 raises the minimum to API 23. Older versions can leave music playing while a new Dart session starts another player.

After changing native plugins, stop the current `flutter run` session and run it again to rebuild and reinstall the app. A hot restart alone cannot replace native plugin code. In an active terminal session, uppercase `R` performs a hot restart; lowercase `r` only hot reloads. Background music volume is initialized when the audio manager is created, so changing it needs a hot restart.

## Offline fonts

The required regular fonts are bundled in `assets/fonts/`; runtime font downloads are disabled. Their source URLs, checksums, and supplied notices are included in that directory. Keep font metrics aligned with the tracing data when changing typography.

## Android build and assets

```powershell
flutter build apk --debug
```

The generated Android splash resources are included in version control so a fresh checkout can build. When intentionally changing splash artwork, regenerate it from `pubspec.yaml` and review the native changes:

```powershell
dart run flutter_native_splash:create
```

Launcher icon generation is separate:

```powershell
dart run flutter_launcher_icons
```

Both generators are dev dependencies; they are not compiled into the app.

The Android release configuration currently uses debug signing. A debug build is suitable for local testing; store distribution requires a separately configured release signing setup. Keep signing secrets outside Git.

## Code style and CI

Format the app code with `dart format` before committing. The tracing data in `lib/data/letter_stroke_paths.dart` is deliberately left unformatted so that each checkpoint list stays on one line:

```powershell
dart format lib/main.dart lib/screens lib/services lib/theme lib/models test
flutter analyze
flutter test
```

The GitHub Actions workflow in `.github/workflows/ci.yml` runs the same format check, analysis and tests, then builds a debug APK, on Flutter 3.29.3 for every push to `main` and every pull request. Bump the pinned Flutter version there together with the README baseline.

## iOS

Apple's iOS Simulator and iOS builds require a Mac with Xcode and the appropriate iOS tooling. VS Code can remain the Flutter editor on that Mac. Windows cannot run Apple's iOS Simulator. Testing on Android does not establish that the iOS app works.

## References

- [Flutter in VS Code](https://docs.flutter.dev/tools/vs-code)
- [Android setup](https://docs.flutter.dev/platform-integration/android/setup)
- [iOS setup](https://docs.flutter.dev/platform-integration/ios/setup)
- [Android command-line tools](https://developer.android.com/tools)
