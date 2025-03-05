# Letter Drawing App

A Flutter-based game that challenges players to trace letters by following predefined stroke checkpoints. The app dynamically validates each stroke, awards points for accuracy, and tracks high scores. It also supports two languages (English and Swedish) and customizable game settings.

## Features

- **Dynamic Stroke Validation:**
    - Each letter is defined by one or more stroke checkpoints.
    - The app checks the user’s drawing for proximity to these checkpoints and validates continuous strokes, split strokes, and even dot strokes (for letters like "i").

- **High Score Tracking:**
    - The game tracks the player’s score and updates the high score if a new record is reached.
    - A congratulatory event is triggered once per session when a new high score is achieved.

- **Multi-Language Support:**
    - The app supports English and Swedish.
    - Users can change the language and game settings from the settings screen.

- **Customizable Game Settings:**
    - Choose your game mode (uppercase, lowercase, or random) and letter order (alphabetic or random) via a settings screen.

- **Visual Feedback:**
    - Custom painting is used to draw the background letter (using Google Fonts).
    - User strokes are shown in red and completed strokes in blue.
    - Animated guidance (in orange) is displayed when help is requested.

## Code Structure

- **GameplayScreen:**  
  Handles gesture detection, stroke validation, score updates, and manages the transition between letters.

- **StrokeCheckpoints:**  
  A model class that maps each letter to its expected stroke checkpoints. Each letter’s stroke is defined by a start point, a list of in-between points, and an end point.

- **CheckpointPainter:**  
  A custom painter that draws:
    - The background letter (using a Google Font).
    - Checkpoint markers for the current stroke (green for the start, red for the end, grey for in-between points).
    - User strokes (in red) and completed strokes (in blue).
    - Animated guidance (in orange) when help is requested.

- **SettingsService:**  
  A service that uses SharedPreferences to store and retrieve settings such as language, game mode, letter order, and high score.
