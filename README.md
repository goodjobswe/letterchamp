# Letter Champ - Every Stroke Counts

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
<img src="https://github.com/goodjobswe/letterchamp/blob/main/assets/screenshots/Screenshot_20250311_180837.jpg" width="300">
<img src="https://github.com/goodjobswe/letterchamp/blob/main/assets/screenshots/Screenshot_20250311_180842.jpg" width="300">
<img src="https://github.com/goodjobswe/letterchamp/blob/main/assets/screenshots/Screenshot_20250311_181029.jpg" width="300">
