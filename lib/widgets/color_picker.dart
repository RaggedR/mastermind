import 'package:flutter/material.dart';

import '../models/code.dart';

class ColorPicker extends StatelessWidget {
  final void Function(PegColor) onColorSelected;
  final PegColor? selectedColor;

  const ColorPicker({
    super.key,
    required this.onColorSelected,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: PegColor.values.map((color) {
        final isSelected = color == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            margin: const EdgeInsets.all(4),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.black26,
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.color.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
