import 'dart:math';

import 'package:flutter/material.dart';

class InfoBar extends StatelessWidget {
  final int remainingCount;
  final double? entropyBits;

  const InfoBar({
    super.key,
    required this.remainingCount,
    this.entropyBits,
  });

  @override
  Widget build(BuildContext context) {
    final totalBits = remainingCount > 1 ? (log(remainingCount) / ln2) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            'Remaining',
            '$remainingCount',
            Icons.grid_view,
          ),
          _buildStat(
            'Uncertainty',
            '${totalBits.toStringAsFixed(1)} bits',
            Icons.analytics_outlined,
          ),
          if (entropyBits != null)
            _buildStat(
              'Info gained',
              '${entropyBits!.toStringAsFixed(1)} bits',
              Icons.lightbulb_outline,
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.amber),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
