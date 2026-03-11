import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../data/models/memory_card_model.dart';

class MemoryGameProvider extends ChangeNotifier {
  List<MemoryCard> cards = [];
  int moves = 0;
  int pairsFound = 0;
  int timeSeconds = 0;
  bool isLocked = false;
  Timer? _timer;

  final String difficulty;
  final int totalPairs;

  int currentLevel = 1;
  bool isGameComplete = false;

  MemoryCard? _firstFlippedCard;

  MemoryGameProvider({required this.difficulty})
      : totalPairs = _getPairsForDifficulty(difficulty) {
    _initializeGame();
  }

  static int _getPairsForDifficulty(String diff) {
    switch (diff) {
      case 'Easy':
        return 3; // 6 cards
      case 'Medium':
        return 6; // 12 cards
      case 'Hard':
        return 8; // 16 cards
      default:
        return 3;
    }
  }

  void _initializeGame() {
    final List<IconData> availableIcons = [
      Icons.favorite,
      Icons.star,
      Icons.home,
      Icons.directions_car,
      Icons.local_florist,
      Icons.pets,
      Icons.music_note,
      Icons.wb_sunny
    ];

    List<IconData> selectedIcons = availableIcons.take(totalPairs).toList();
    List<IconData> gameIcons = [...selectedIcons, ...selectedIcons];
    gameIcons.shuffle();

    cards = List.generate(
      gameIcons.length,
      (index) => MemoryCard(id: index, icon: gameIcons[index]),
    );
    notifyListeners();
  }

  void startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeSeconds++;
      notifyListeners();
    });
  }

  void flipCard(MemoryCard card) async {
    if (isLocked || card.isFaceUp || card.isMatched) return;

    startTimer();
    card.isFaceUp = true;
    notifyListeners();

    if (_firstFlippedCard == null) {
      _firstFlippedCard = card;
    } else {
      moves++;
      _checkForMatch(card);
    }
  }

  void _checkForMatch(MemoryCard secondCard) async {
    isLocked = true;
    notifyListeners();

    if (_firstFlippedCard!.icon == secondCard.icon) {
      // Match found
      _firstFlippedCard!.isMatched = true;
      secondCard.isMatched = true;
      pairsFound++;

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }

      if (pairsFound == totalPairs) {
        _timer?.cancel();
        isGameComplete = true;
      }
    } else {
      // No match, delay and flip back
      await Future.delayed(const Duration(milliseconds: 1000));
      _firstFlippedCard!.isFaceUp = false;
      secondCard.isFaceUp = false;
    }

    _firstFlippedCard = null;
    isLocked = false;
    notifyListeners();
  }

  void resetForNextLevel() {
    currentLevel++;
    moves = 0;
    pairsFound = 0;
    timeSeconds = 0;
    isGameComplete = false;
    _firstFlippedCard = null;
    isLocked = false;
    _timer?.cancel();
    _timer = null;
    _initializeGame(); // This will reshuffle and generate a new board
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
