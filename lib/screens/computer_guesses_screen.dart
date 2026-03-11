import 'package:flutter/material.dart';

import '../game/ai_solver.dart';
import '../game/game_engine.dart';
import '../models/code.dart';
import '../models/feedback.dart';
import '../models/guess_entry.dart';
import '../widgets/code_input.dart';
import '../widgets/feedback_input.dart';
import '../widgets/info_bar.dart';

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
  double _panelFraction = 0.0; // 0 = front on top, 1 = front gone


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
      // Auto-reveal enough to show the guesses
      _panelFraction = (_guesses.length * 0.12).clamp(0.0, 0.6);

      if (feedback.isCorrect) {
        _solved = true;
        _currentGuess = null;
        _currentEntropy = null;
      } else {
        _makeNextGuess();
      }
    });
  }

  Widget _buildPeg(Color c, {double size = 36}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Color.lerp(c, Colors.white, 0.3)!,
            c,
            Color.lerp(c, Colors.black, 0.2)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: const [
          BoxShadow(
              color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
    );
  }

  Widget _buildDragHandle(double maxSlide) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        setState(() {
          _panelFraction =
              (_panelFraction + details.primaryDelta! / maxSlide)
                  .clamp(0.0, 1.0);
        });
      },
      onTap: () {
        setState(() {
          _panelFraction = _panelFraction > 0.5 ? 0.0 : 1.0;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.amber.shade400,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuessRow(int guessIndex, GuessEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${guessIndex + 1}.',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          for (int j = 0; j < 4; j++) _buildPeg(entry.guess[j].color),
          const SizedBox(width: 16),
          const Text('→  ', style: TextStyle(fontSize: 18)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kFeedbackExactColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white38, width: 1),
            ),
            child: Text(
              '${entry.feedback.black} ✓',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kFeedbackMisplacedColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white38, width: 1),
            ),
            child: Text(
              '${entry.feedback.white} ~',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_needsSecret) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Cracks Your Code'),
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
      ),
      body: Column(
        children: [
          // Secret code reminder
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
                  _buildPeg(_humanSecret![i].color, size: 28),
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
          // Victory text above the stack when solved
          if (_solved)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'AI cracked it in ${_guesses.length} guesses!',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Play Again'),
                  ),
                ],
              ),
            ),
          // Main area: BACK (history) with FRONT (controls) on top
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxH = constraints.maxHeight;
                final slideOffset = maxH * _panelFraction;

                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // BACK: scrollable guess history
                    Positioned.fill(
                      child: _guesses.isEmpty
                          ? const Center(
                              child: Text('No guesses yet',
                                  style: TextStyle(color: Colors.grey)),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _guesses.length,
                              itemBuilder: (context, index) {
                                return _buildGuessRow(index, _guesses[index]);
                              },
                            ),
                    ),
                    // FRONT: AI guess + feedback controls
                    if (!_solved && _currentGuess != null)
                      Positioned(
                        top: slideOffset,
                        left: 0,
                        right: 0,
                        height: maxH,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            border: Border(
                              top: BorderSide(
                                  color:
                                      Colors.white.withValues(alpha: 0.2),
                                  width: 2),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildDragHandle(maxH),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Column(
                                          children: [
                                            Text(
                                              'AI guesses:',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(
                                                  4,
                                                  (i) => _buildPeg(
                                                      _currentGuess![i].color,
                                                      size: 48)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_errorMessage != null)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 8),
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(
                                                color: Colors.redAccent),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 8, 16, 16),
                                        child:
                                            FeedbackInput(onSubmit: _onFeedback),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
