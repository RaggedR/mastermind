import 'package:flutter/material.dart';

import '../models/code.dart';
import 'color_picker.dart';

class CodeInput extends StatefulWidget {
  final void Function(Code) onSubmit;
  final String submitLabel;

  const CodeInput({
    super.key,
    required this.onSubmit,
    this.submitLabel = 'Submit Guess',
  });

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  final List<PegColor?> _pegs = [null, null, null, null];
  int _selectedSlot = 0;

  bool get _isComplete => _pegs.every((p) => p != null);

  void _selectColor(PegColor color) {
    setState(() {
      _pegs[_selectedSlot] = color;
      // Auto-advance to next empty slot
      for (int i = 0; i < 4; i++) {
        final next = (_selectedSlot + 1 + i) % 4;
        if (_pegs[next] == null) {
          _selectedSlot = next;
          return;
        }
      }
    });
  }

  void _submit() {
    if (!_isComplete) return;
    final code = Code(List<PegColor>.from(_pegs));
    widget.onSubmit(code);
    setState(() {
      for (int i = 0; i < 4; i++) {
        _pegs[i] = null;
      }
      _selectedSlot = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Peg slots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final isSelected = i == _selectedSlot;
            return GestureDetector(
              onTap: () => setState(() => _selectedSlot = i),
              child: Container(
                margin: const EdgeInsets.all(6),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _pegs[i]?.color ?? Colors.grey.shade800,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.amber : Colors.white24,
                    width: isSelected ? 3 : 1.5,
                  ),
                ),
                child: _pegs[i] == null
                    ? Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        ColorPicker(onColorSelected: _selectColor),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  for (int i = 0; i < 4; i++) {
                    _pegs[i] = null;
                  }
                  _selectedSlot = 0;
                });
              },
              child: const Text('Clear'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isComplete ? _submit : null,
              child: Text(widget.submitLabel),
            ),
          ],
        ),
      ],
    );
  }
}
