import 'package:flutter/material.dart';

import '../models/match_state.dart';
import 'human_guesses_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.psychology,
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              'MASTERMIND',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '4 pegs · 6 colors · 1296 possibilities',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 48),
            _buildRulesCard(context),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                final matchState = MatchState();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        HumanGuessesScreen(matchState: matchState),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Match'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to play',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const _RuleRow(
              number: '1',
              text: 'You crack the computer\'s secret code',
            ),
            const _RuleRow(
              number: '2',
              text: 'The AI cracks your secret code',
            ),
            const _RuleRow(
              number: '3',
              text: 'Fewest guesses wins!',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _feedbackLegend(Colors.black, 'Correct color & position'),
                const SizedBox(width: 16),
                _feedbackLegend(Colors.white, 'Correct color, wrong spot'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedbackLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String number;
  final String text;

  const _RuleRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.amber,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}
