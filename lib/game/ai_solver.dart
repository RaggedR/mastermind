import 'dart:math';

import '../models/code.dart';
import '../models/feedback.dart';
import 'game_engine.dart';

class AiSolver {
  List<Code> _remaining = List.of(allCodes);
  int _guessCount = 0;

  /// Precomputed first guess: AABC pattern (red, red, blue, green).
  static final Code _firstGuess = Code([
    PegColor.red,
    PegColor.red,
    PegColor.blue,
    PegColor.green,
  ]);

  int get remainingCount => _remaining.length;
  int get guessCount => _guessCount;

  /// Reset the solver for a new game.
  void reset() {
    _remaining = List.of(allCodes);
    _guessCount = 0;
  }

  /// Get the AI's next guess using entropy maximization.
  Code nextGuess() {
    _guessCount++;

    if (_guessCount == 1) return _firstGuess;
    if (_remaining.length == 1) return _remaining.first;

    Code? bestGuess;
    double bestEntropy = -1;
    bool bestInRemaining = false;

    for (final candidate in allCodes) {
      final partition = <GuessFeedback, int>{};

      for (final secret in _remaining) {
        final fb = GameEngine.computeFeedback(candidate, secret);
        partition[fb] = (partition[fb] ?? 0) + 1;
      }

      final entropy = _entropy(partition.values, _remaining.length);
      final inRemaining = _remaining.contains(candidate);

      // Pick highest entropy; tie-break by preferring codes still in S
      if (entropy > bestEntropy ||
          (entropy == bestEntropy && inRemaining && !bestInRemaining)) {
        bestEntropy = entropy;
        bestGuess = candidate;
        bestInRemaining = inRemaining;
      }
    }

    return bestGuess!;
  }

  /// Update the remaining set after receiving feedback for a guess.
  void applyFeedback(Code guess, GuessFeedback feedback) {
    _remaining = _remaining.where((code) {
      return GameEngine.computeFeedback(guess, code) == feedback;
    }).toList();
  }

  /// Compute Shannon entropy from partition bucket sizes.
  double _entropy(Iterable<int> bucketSizes, int total) {
    double h = 0;
    for (final count in bucketSizes) {
      if (count == 0) continue;
      final p = count / total;
      h -= p * (log(p) / ln2);
    }
    return h;
  }

  /// Compute entropy of the current remaining set for the given guess.
  /// Used for display purposes (info bar).
  double entropyForGuess(Code guess) {
    final partition = <GuessFeedback, int>{};
    for (final secret in _remaining) {
      final fb = GameEngine.computeFeedback(guess, secret);
      partition[fb] = (partition[fb] ?? 0) + 1;
    }
    return _entropy(partition.values, _remaining.length);
  }
}
