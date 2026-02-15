import 'package:flutter/material.dart';

import '../models/feedback.dart';

class FeedbackInput extends StatefulWidget {
  final void Function(GuessFeedback) onSubmit;

  const FeedbackInput({super.key, required this.onSubmit});

  @override
  State<FeedbackInput> createState() => _FeedbackInputState();
}

class _FeedbackInputState extends State<FeedbackInput> {
  int _black = 0;
  int _white = 0;

  bool get _isValid => _black + _white <= 4 && _black >= 0 && _white >= 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Provide feedback for the AI\'s guess:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCounter(
              label: 'Black (exact)',
              value: _black,
              color: Colors.black,
              textColor: Colors.white,
              onIncrement: () {
                if (_black + _white < 4) setState(() => _black++);
              },
              onDecrement: () {
                if (_black > 0) setState(() => _black--);
              },
            ),
            const SizedBox(width: 24),
            _buildCounter(
              label: 'White (color only)',
              value: _white,
              color: Colors.white,
              textColor: Colors.black,
              onIncrement: () {
                if (_black + _white < 4) setState(() => _white++);
              },
              onDecrement: () {
                if (_white > 0) setState(() => _white--);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isValid
              ? () {
                  widget.onSubmit(
                      GuessFeedback(black: _black, white: _white));
                  setState(() {
                    _black = 0;
                    _white = 0;
                  });
                }
              : null,
          child: const Text('Submit Feedback'),
        ),
      ],
    );
  }

  Widget _buildCounter({
    required String label,
    required int value,
    required Color color,
    required Color textColor,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_circle_outline),
              iconSize: 28,
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: Text(
                  '$value',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add_circle_outline),
              iconSize: 28,
            ),
          ],
        ),
      ],
    );
  }
}
