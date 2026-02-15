# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
flutter pub get
flutter run -d chrome          # web
flutter run -d macos            # desktop
flutter build web --profile     # web build (profile mode gives readable errors)
flutter analyze                 # lint
flutter test                    # tests
```

No external dependencies beyond Flutter SDK. Pure `setState` state management.

## Architecture

Two-round match flow, each screen passed a shared mutable `MatchState`:

```
HomeScreen → HumanGuessesScreen (Round 1) → ComputerGuessesScreen (Round 2) → ScoreScreen
                                                                                  ↓
                                                                          Navigator.popUntil(first)
```

### Layers

- **models/** — Data: `Code` (4 pegs from 6-color enum), `GuessFeedback` (black/white counts), `GuessEntry` (guess+feedback pair), `MatchState` (mutable score holder passed by reference)
- **game/** — Logic: `GameEngine` (two-pass feedback algorithm), `AiSolver` (entropy-maximizing codebreaker)
- **screens/** — Full-page views, own their state via `StatefulWidget`
- **widgets/** — Reusable UI: `CodeInput` (used for both guessing and secret-setting via `submitLabel`), `PegBoard` (guess history), `InfoBar` (remaining count + bits)

### Key data: `allCodes`

Top-level `final` in `code.dart` — lazily generates all 1296 codes via base-6 enumeration. Both screens and the solver reference this shared list.

## Core Algorithm

**`ai_solver.dart::nextGuess()`** — Shannon entropy maximization:

1. First guess hardcoded: `[Red, Red, Blue, Green]` (AABC pattern, ~3.04 bits, activates all 14 feedback channels)
2. For each of 1296 candidates, partition remaining set S by feedback → compute H(g) = −Σ pᵢ log₂ pᵢ → pick argmax
3. Tie-break: prefer candidates still in S (could be correct)
4. Cost: O(1296 × |S|) per turn; |S| shrinks exponentially

**14 valid feedbacks** (not 15): (3,1) is impossible — if 3 pegs are exact, the 4th either matches (4,0) or doesn't (3,0).

**Feedback validation** in Round 2: `computeFeedback(guess, humanSecret)` is compared to human's claimed feedback; mismatches rejected with explanation.

## Gotchas

- **`List.cast<T>()` is lazy** — creates a view, not a copy. `CodeInput` uses `List<PegColor>.from(_pegs)` to avoid mutation after submit.
- **`debugPrint` stripped in release builds** — use `print()` for web console output.
- **Flutter web service worker** aggressively caches `main.dart.js`. Serve on a new port or clear site data when debugging stale builds.
- **Feedback chip colors** are hardcoded in both `_GuessRow` (human_guesses_screen) and `PegBoard` — no shared constant. Green = `Color(0xFF2E7D32)`, amber = `Color(0xFFF57F17)`.
- **`MatchState` is mutable** and passed by reference between screens — unconventional for Flutter but works for this simple flow.
