import 'package:flutter/material.dart';

import '../game/ai_solver.dart';
import '../game/game_engine.dart';
import '../models/code.dart';
import '../models/feedback.dart';
import '../models/guess_entry.dart';
import '../widgets/code_input.dart';
import '../widgets/feedback_input.dart';
import '../widgets/info_bar.dart';
import '../widgets/peg_board.dart';

class ComputerGuessesScreen extends StatefulWidget {
  const ComputerGuessesScreen({super.key});

  @override
  State<ComputerGuessesScreen> createState() => _ComputerGuessesScreenState();
}

class _ComputerGuessesScreenState extends State<ComputerGuessesScreen> {
  final AiSolver _solver = AiSolver();
  final List<GuessEntry> _guesses = [];
  Code? _currentGuess;
  double? _currentEntropy;
  bool _solved = false;
  bool _needsSecret = true;
  Code? _humanSecret;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  void _setSecret(Code secret) {
    setState(() {
      _humanSecret = secret;
      _needsSecret = false;
      _makeNextGuess();
    });
  }

  void _makeNextGuess() {
    final guess = _solver.nextGuess();
    setState(() {
      _currentGuess = guess;
      _currentEntropy = _solver.entropyForGuess(guess);
    });
  }

  void _onFeedback(GuessFeedback feedback) {
    final guess = _currentGuess!;

    // Validate that the feedback is consistent
    final expectedFeedback = GameEngine.computeFeedback(guess, _humanSecret!);
    if (feedback != expectedFeedback) {
      setState(() {
        _errorMessage =
            'That feedback is inconsistent! For this guess against your secret, '
            'the correct feedback is ${expectedFeedback.black} black, '
            '${expectedFeedback.white} white.';
      });
      return;
    }

    _solver.applyFeedback(guess, feedback);

    setState(() {
      _errorMessage = null;
      _guesses.add(GuessEntry(guess: guess, feedback: feedback));

      if (feedback.isCorrect) {
        _solved = true;
        _currentGuess = null;
        _currentEntropy = null;
      } else {
        _makeNextGuess();
      }
    });
  }

  void _proceed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_needsSecret) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Cracks Your Code'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 48, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  'Pick your secret code',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'The AI will try to crack it!',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                CodeInput(
                  onSubmit: _setSecret,
                  submitLabel: 'Set Secret',
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Cracks Your Code'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Show the human's secret code as a reminder
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey.shade900,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Your secret:  ',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                for (int i = 0; i < 4; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _humanSecret![i].color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: InfoBar(
              remainingCount: _solver.remainingCount,
              entropyBits: _currentEntropy,
            ),
          ),
          Expanded(
            child: PegBoard(guesses: _guesses
            ),
          ),
          if (_solved)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'AI cracked it in ${_guesses.length} guesses!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _proceed,
                    icon: const Icon(Icons.home),
                    label: const Text('Play Again'),
                  ),
                ],
              ),
            )
          else if (_currentGuess != null) ...[
            // Show AI's current guess
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'AI guesses:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _currentGuess![i].color,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white24, width: 1.5),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FeedbackInput(onSubmit: _onFeedback),
            ),
          ],
        ],
      ),
    );
  }
}
