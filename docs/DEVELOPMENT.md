# Local development

Letterchamp currently has Android and iOS app targets. The repository does not contain web or Windows app runners.

## Baseline

The September 2026 recovery uses Flutter 3.29.3 with its bundled Dart 3.7.2 and the committed `pubspec.lock`. This establishes a reproducible baseline, not a claim that these are the latest versions. Upgrade Flutter, packages, and native tooling in a separate tested change.

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

The Android release configuration currently uses debug signing. A debug build is suitable for local testing; store distribution requires a separately configured release signing setup. Keep signing secrets outside Git.

## iOS

Apple's iOS Simulator and iOS builds require a Mac with Xcode and the appropriate iOS tooling. VS Code can remain the Flutter editor on that Mac. Windows cannot run Apple's iOS Simulator. Testing on Android does not establish that the iOS app works.

## References

- [Flutter in VS Code](https://docs.flutter.dev/tools/vs-code)
- [Android setup](https://docs.flutter.dev/platform-integration/android/setup)
- [iOS setup](https://docs.flutter.dev/platform-integration/ios/setup)
- [Android command-line tools](https://developer.android.com/tools)
