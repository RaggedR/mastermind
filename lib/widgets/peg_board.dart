import 'package:flutter/material.dart';

import '../models/code.dart';
import '../models/guess_entry.dart';

class PegBoard extends StatelessWidget {
  final List<GuessEntry> guesses;

  const PegBoard({super.key, required this.guesses});

  @override
  Widget build(BuildContext context) {
    if (guesses.isEmpty) {
      return const Center(
        child: Text(
          'No guesses yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: guesses.length,
      itemBuilder: (context, index) {
        final entry = guesses[index];
        final fb = entry.feedback;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${index + 1}.',
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
                  fb.black, '✓ exact', const Color(0xFF2E7D32), Colors.white),
              const SizedBox(width: 6),
              _feedbackChip(
                  fb.white, '~ wrong spot', const Color(0xFFF57F17), Colors.white),
            ],
          ),
        );
      },
    );
  }

  Widget _colorPeg(PegColor peg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 36,
      height: 36,
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
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
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
        '$count $label',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
