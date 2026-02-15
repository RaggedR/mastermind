import 'dart:math';

import '../models/code.dart';
import '../models/feedback.dart';

class GameEngine {
  static final _random = Random();

  /// Compute Mastermind feedback for a [guess] against a [secret].
  ///
  /// Black pegs = correct color in correct position.
  /// White pegs = correct color in wrong position.
  static GuessFeedback computeFeedback(Code guess, Code secret) {
    int black = 0;
    final secretRemaining = <PegColor>[];
    final guessRemaining = <PegColor>[];

    // Pass 1: exact matches
    for (int i = 0; i < 4; i++) {
      if (guess[i] == secret[i]) {
        black++;
      } else {
        secretRemaining.add(secret[i]);
        guessRemaining.add(guess[i]);
      }
    }

    // Pass 2: color-only matches from remaining
    int white = 0;
    final secretCounts = <PegColor, int>{};
    for (final c in secretRemaining) {
      secretCounts[c] = (secretCounts[c] ?? 0) + 1;
    }
    for (final c in guessRemaining) {
      if ((secretCounts[c] ?? 0) > 0) {
        white++;
        secretCounts[c] = secretCounts[c]! - 1;
      }
    }

    return GuessFeedback(black: black, white: white);
  }

  /// Check if the claimed [feedback] for [guess] is consistent with
  /// at least one code in [remainingCodes].
  static bool validateFeedback(
    Code guess,
    GuessFeedback feedback,
    List<Code> remainingCodes,
  ) {
    for (final code in remainingCodes) {
      if (computeFeedback(guess, code) == feedback) {
        return true;
      }
    }
    return false;
  }

  /// Generate a random secret code.
  static Code randomCode() {
    return allCodes[_random.nextInt(allCodes.length)];
  }
}
