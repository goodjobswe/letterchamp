# Letter Champ - Every Stroke Counts

## Development and project status

See [local development](docs/DEVELOPMENT.md) for Flutter, VS Code, Android emulator, and iOS setup. See the [project review](docs/PROJECT_REVIEW.md) for architecture, recovery findings, and the checklist before public release.

The current recovery baseline is Flutter 3.29.3 / Dart 3.7.2. Android and iOS runners are included; iOS still requires validation on a Mac. Dependency modernization and public-release preparation are ongoing.

The game loads user settings to generate a list of letters (including additional Swedish characters when needed) formatted by the selected game mode. A single letter is displayed on the screen, and the player traces it on a dedicated canvas. The drawn strokes are compared against predefined checkpoints for accuracy, with support for both continuous and dot strokes. Correct tracing awards points and bonus multipliers for consecutive letters, while errors result in penalties and bonus resets. An optional help feature provides an animated guide for the expected stroke path, with the first use free and subsequent requests deducting points. The interface adapts its instructions and feedback based on the selected language, ensuring a dynamic and engaging user experience.

## Gameplay Summary:

- **Customizable Game Settings:**
  - Choose your game mode (uppercase, lowercase, or random) and letter order (alphabetic or random) via a settings screen.

- **Letter Setup:**
  - The game loads user settings (language, game mode, letter order) to generate a list of letters.
  - For Swedish, additional characters (å, ä, ö) are included.
  - Letters are formatted (uppercase, lowercase, or random) based on the chosen game mode.

- **Tracing Mechanics:**
  - A single letter is displayed on the screen for the player to trace.
  - The player draws on a dedicated canvas; their strokes are recorded and compared against predefined stroke checkpoints for that letter.
  - The system checks the stroke’s validity (including support for dot strokes and combining multiple stroke segments if needed).

- **Scoring & Feedback:**
  - Correctly traced letters earn points and bonus multipliers for consecutive successes.
  - An incorrect stroke results in a penalty (deduction of points) and resets the bonus streak.
  - Feedback is provided via snack bars with dynamic messages (both greetings and error alerts).

- **Help Feature:**
  - Players can tap a help icon to reveal an animated guide showing the expected stroke path.
  - The first help request is free; subsequent requests deduct a set number of points.

- **Visual & Interaction Elements:**
  - A game-themed background with a dark overlay sets the stage.
  - The current letter is displayed prominently, while the drawing area shows both the user's strokes and, when requested, the guided stroke animation.
  - The interface adapts text and labels based on the selected language (English or Swedish).

## Screenshots:
<img src="assets/screenshots/Screenshot_20250312_080245.jpg" align="left" width="300">
<img src="assets/screenshots/Screenshot_20250312_080308.jpg" align="left" width="300">
<img src="assets/screenshots/Screenshot_20250312_080318.jpg" align="left" width="300">
<img src="assets/screenshots/Screenshot_20250312_080324.jpg" align="left" width="300">
<img src="assets/screenshots/Screenshot_20250312_080333.jpg" align="left" width="300">
<img src="assets/screenshots/Screenshot_20250312_080423.jpg" align="left" width="300">
<img src="assets/screenshots/Screenshot_20250312_080441.jpg" align="left" width="300">
