import 'dart:ui';

const Color kFeedbackExactColor = Color(0xFF2E7D32);
const Color kFeedbackMisplacedColor = Color(0xFFF57F17);

class GuessFeedback {
  final int black;
  final int white;

  const GuessFeedback({required this.black, required this.white});

  bool get isCorrect => black == 4;

  @override
  bool operator ==(Object other) {
    if (other is! GuessFeedback) return false;
    return black == other.black && white == other.white;
  }

  @override
  int get hashCode => Object.hash(black, white);

  @override
  String toString() => '${black}B ${white}W';
}
