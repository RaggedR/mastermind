import 'package:flutter/material.dart';

import '../models/match_state.dart';

class ScoreScreen extends StatelessWidget {
  final MatchState matchState;

  const ScoreScreen({super.key, required this.matchState});

  @override
  Widget build(BuildContext context) {
    final result = matchState.result;
    final isHumanWin = result == 'You win!';
    final isTie = result == "It's a tie!";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Results'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHumanWin
                  ? Icons.emoji_events
                  : isTie
                      ? Icons.handshake
                      : Icons.smart_toy,
              size: 80,
              color: isHumanWin
                  ? Colors.amber
                  : isTie
                      ? Colors.grey
                      : Colors.cyanAccent,
            ),
            const SizedBox(height: 16),
            Text(
              result,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isHumanWin
                        ? Colors.amber
                        : isTie
                            ? Colors.grey.shade300
                            : Colors.cyanAccent,
                  ),
            ),
            const SizedBox(height: 32),
            _buildScoreCard(context),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('Play Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 48),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildScoreRow(
              context,
              icon: Icons.person,
              label: 'You',
              guesses: matchState.humanGuesses!,
              color: Colors.amber,
            ),
            const Divider(height: 24),
            _buildScoreRow(
              context,
              icon: Icons.smart_toy,
              label: 'AI',
              guesses: matchState.computerGuesses!,
              color: Colors.cyanAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int guesses,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        Text(
          '$guesses guesses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
