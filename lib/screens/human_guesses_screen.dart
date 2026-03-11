import 'package:flutter/material.dart';

import '../game/game_engine.dart';
import '../models/code.dart';
import '../models/feedback.dart';
import '../models/guess_entry.dart';
import '../widgets/code_input.dart';
import '../widgets/info_bar.dart';

class HumanGuessesScreen extends StatefulWidget {
  const HumanGuessesScreen({super.key});

  @override
  State<HumanGuessesScreen> createState() => _HumanGuessesScreenState();
}

class _HumanGuessesScreenState extends State<HumanGuessesScreen> {
  late final Code _secret;
  final List<GuessEntry> _guesses = [];
  bool _solved = false;
  List<Code> _remaining = List.of(allCodes);
  double _panelFraction = 0.0; // 0 = front on top, 1 = front gone


  @override
  void initState() {
    super.initState();
    _secret = GameEngine.randomCode();
    // ignore: avoid_print
    print('SECRET: $_secret');
  }

  void _onGuess(Code guess) {
    final feedback = GameEngine.computeFeedback(guess, _secret);
    // ignore: avoid_print
    print('GUESS: $guess → ${feedback.black}B ${feedback.white}W');

    _remaining = _remaining.where((code) {
      return GameEngine.computeFeedback(guess, code) == feedback;
    }).toList();
    // ignore: avoid_print
    print('REMAINING: ${_remaining.length}');

    setState(() {
      _guesses.add(GuessEntry(guess: guess, feedback: feedback));
      // Auto-reveal enough to show the guesses
      _panelFraction = (_guesses.length * 0.12).clamp(0.0, 0.6);
      if (feedback.isCorrect) {
        _solved = true;
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
          // Drag down → front slides down → reveals history
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

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    print('BUILD: remaining=${_remaining.length}, guesses=${_guesses.length}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crack the Code'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InfoBar(remainingCount: _remaining.length),
          ),
          if (_remaining.length <= 6 && _remaining.isNotEmpty && !_solved)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  Text(
                    _remaining.length == 1
                        ? 'Only one possibility left!'
                        : 'Possible codes:',
                    style: TextStyle(
                      fontSize: 13,
                      color: _remaining.length == 1
                          ? Colors.greenAccent
                          : Colors.grey,
                      fontWeight: _remaining.length == 1
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _remaining.map((code) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < 4; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildPeg(code[i].color, size: 28),
                                  Text(
                                    code[i].label[0],
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          // Victory text above the stack when solved
          if (_solved)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Cracked it in ${_guesses.length} guesses!',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.greenAccent,
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
          // Main area: BACK (history) with FRONT (CodeInput) on top
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxH = constraints.maxHeight;
                final slideOffset = maxH * _panelFraction;

                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // BACK: scrollable guess history (always full size)
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
                                return _GuessRow(
                                  index: index + 1,
                                  entry: _guesses[index],
                                );
                              },
                            ),
                    ),
                    // FRONT: CodeInput panel (slides down, clipped at bottom)
                    if (!_solved)
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
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 0, 16, 16),
                                child: CodeInput(onSubmit: _onGuess),
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

class _GuessRow extends StatelessWidget {
  final int index;
  final GuessEntry entry;

  const _GuessRow({required this.index, required this.entry});

  @override
  Widget build(BuildContext context) {
    final fb = entry.feedback;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$index.',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          _colorPeg(entry.guess[0]),
          _colorPeg(entry.guess[1]),
          _colorPeg(entry.guess[2]),
          _colorPeg(entry.guess[3]),
          const SizedBox(width: 16),
          const Text('→  ', style: TextStyle(fontSize: 18)),
          _feedbackChip(
              fb.black, ' ✓', kFeedbackExactColor, Colors.white),
          const SizedBox(width: 6),
          _feedbackChip(
              fb.white, ' ~', kFeedbackMisplacedColor, Colors.white),
        ],
      ),
    );
  }

  Widget _colorPeg(PegColor peg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Color.lerp(peg.color, Colors.white, 0.3)!,
            peg.color,
            Color.lerp(peg.color, Colors.black, 0.2)!,
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

  Widget _feedbackChip(int count, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white38, width: 1),
      ),
      child: Text(
        '$count$label',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
