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
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  Color.lerp(color.color, Colors.white, 0.3)!,
                  color.color,
                  Color.lerp(color.color, Colors.black, 0.2)!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.black26,
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: [
                const BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                if (isSelected)
                  BoxShadow(
                    color: color.color.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
