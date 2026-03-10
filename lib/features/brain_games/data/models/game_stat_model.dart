class GameStat {
  final int? id;
  final String userId;
  final String gameName;
  final String difficulty;
  final int moves;
  final int timeSeconds;
  final String date;

  GameStat({
    this.id,
    required this.userId,
    required this.gameName,
    required this.difficulty,
    required this.moves,
    required this.timeSeconds,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'gameName': gameName,
      'difficulty': difficulty,
      'moves': moves,
      'timeSeconds': timeSeconds,
      'date': date,
    };
  }
}
