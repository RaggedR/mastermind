class MatchState {
  int? humanGuesses;
  int? computerGuesses;

  bool get isComplete => humanGuesses != null && computerGuesses != null;

  String get result {
    if (!isComplete) return 'Match incomplete';
    if (humanGuesses! < computerGuesses!) return 'You win!';
    if (humanGuesses! > computerGuesses!) return 'Computer wins!';
    return "It's a tie!";
  }
}
