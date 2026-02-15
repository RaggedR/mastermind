import 'package:flutter/material.dart';

import '../models/feedback.dart';

class FeedbackDisplay extends StatelessWidget {
  final GuessFeedback feedback;

  const FeedbackDisplay({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final pegs = <_PegType>[];
    for (int i = 0; i < feedback.black; i++) {
      pegs.add(_PegType.black);
    }
    for (int i = 0; i < feedback.white; i++) {
      pegs.add(_PegType.white);
    }
    while (pegs.length < 4) {
      pegs.add(_PegType.empty);
    }

    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildPeg(pegs[0]), _buildPeg(pegs[1])],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildPeg(pegs[2]), _buildPeg(pegs[3])],
          ),
        ],
      ),
    );
  }

  Widget _buildPeg(_PegType type) {
    Color fill;
    Color border;
    switch (type) {
      case _PegType.black:
        fill = Colors.grey.shade900;
        border = Colors.white70;
      case _PegType.white:
        fill = Colors.white;
        border = Colors.grey.shade400;
      case _PegType.empty:
        fill = Colors.grey.shade700;
        border = Colors.grey.shade600;
    }
    return Container(
      margin: const EdgeInsets.all(2),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1.5),
      ),
    );
  }
}

enum _PegType { black, white, empty }
