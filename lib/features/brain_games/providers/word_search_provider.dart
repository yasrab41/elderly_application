import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:elderly_prototype_app/core/constants.dart';

class Point {
  final int x, y;
  Point(this.x, this.y);
  @override
  bool operator ==(Object other) =>
      other is Point && x == other.x && y == other.y;
  @override
  int get hashCode => Object.hash(x, y);
}

class WordSearchProvider extends ChangeNotifier {
  final String difficulty;

  int gridSize = 6;
  List<String> targetWords = [];
  List<String> foundWords = [];
  List<List<String>> grid = [];
  Set<Point> foundCells = {};

  Point? firstTap;
  int timeSeconds = 0;
  int currentLevel = 1;
  int attempts = 0; // Tracks moves/attempts for stats
  bool isGameComplete = false;
  Timer? _timer;

  WordSearchProvider({required this.difficulty}) {
    _initializeLevel();
  }

  void _initializeLevel() {
    _setupDifficultyParameters();
    _generateGrid();
    startTimer();
  }

  void _setupDifficultyParameters() {
    final random = Random();
    List<String> wordPool = [];

    switch (difficulty) {
      case 'Easy':
        gridSize = 6;
        wordPool = List.from(AppStrings.easyWords)..shuffle(random);
        targetWords = wordPool.take(3).toList();
        break;
      case 'Medium':
        gridSize = 8;
        wordPool = List.from(AppStrings.mediumWords)..shuffle(random);
        targetWords = wordPool.take(5).toList();
        break;
      case 'Hard':
        gridSize = 10;
        wordPool = List.from(AppStrings.hardWords)..shuffle(random);
        targetWords = wordPool.take(8).toList();
        break;
    }
  }

  void _generateGrid() {
    final random = Random();
    grid = List.generate(gridSize, (_) => List.filled(gridSize, ' '));

    // Define directions based on difficulty
    List<Point> directions = [Point(1, 0), Point(0, 1)]; // Easy: Right, Down
    if (difficulty == 'Medium')
      directions.addAll([Point(-1, 0), Point(0, -1)]); // Add Left, Up
    if (difficulty == 'Hard')
      directions.addAll([
        Point(1, 1),
        Point(-1, -1),
        Point(1, -1),
        Point(-1, 1)
      ]); // Add Diagonals

    for (String word in targetWords) {
      bool placed = false;
      int tries = 0;
      while (!placed && tries < 100) {
        Point dir = directions[random.nextInt(directions.length)];
        int startX = random.nextInt(gridSize);
        int startY = random.nextInt(gridSize);

        if (_canPlaceWord(word, startX, startY, dir.x, dir.y)) {
          _placeWord(word, startX, startY, dir.x, dir.y);
          placed = true;
        }
        tries++;
      }
    }

    // Fill empty spaces with random letters
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (grid[y][x] == ' ') {
          grid[y][x] = letters[random.nextInt(letters.length)];
        }
      }
    }
    notifyListeners();
  }

  bool _canPlaceWord(String word, int x, int y, int dx, int dy) {
    if (x + (word.length - 1) * dx < 0 ||
        x + (word.length - 1) * dx >= gridSize) return false;
    if (y + (word.length - 1) * dy < 0 ||
        y + (word.length - 1) * dy >= gridSize) return false;

    for (int i = 0; i < word.length; i++) {
      if (grid[y + i * dy][x + i * dx] != ' ' &&
          grid[y + i * dy][x + i * dx] != word[i]) {
        return false;
      }
    }
    return true;
  }

  void _placeWord(String word, int x, int y, int dx, int dy) {
    for (int i = 0; i < word.length; i++) {
      grid[y + i * dy][x + i * dx] = word[i];
    }
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeSeconds++;
      notifyListeners();
    });
  }

  void handleCellTap(int x, int y) async {
    if (isGameComplete) return;

    if (firstTap == null) {
      firstTap = Point(x, y);
      notifyListeners();
    } else {
      attempts++;
      _checkWordSelection(firstTap!, Point(x, y));
      firstTap = null;
    }
  }

  void _checkWordSelection(Point p1, Point p2) async {
    int dx = p2.x - p1.x;
    int dy = p2.y - p1.y;

    // Check if it's a valid straight or diagonal line
    if (dx != 0 && dy != 0 && dx.abs() != dy.abs()) {
      notifyListeners(); // Invalid line, clear selection
      return;
    }

    int steps = max(dx.abs(), dy.abs());
    int stepX = dx == 0 ? 0 : (dx ~/ dx.abs());
    int stepY = dy == 0 ? 0 : (dy ~/ dy.abs());

    String selectedWord = '';
    List<Point> currentSelection = [];

    for (int i = 0; i <= steps; i++) {
      int cx = p1.x + i * stepX;
      int cy = p1.y + i * stepY;
      selectedWord += grid[cy][cx];
      currentSelection.add(Point(cx, cy));
    }

    // Check forward and backward
    String reversedWord = selectedWord.split('').reversed.join('');

    if ((targetWords.contains(selectedWord) &&
            !foundWords.contains(selectedWord)) ||
        (targetWords.contains(reversedWord) &&
            !foundWords.contains(reversedWord))) {
      String matchedWord =
          targetWords.contains(selectedWord) ? selectedWord : reversedWord;
      foundWords.add(matchedWord);
      foundCells.addAll(currentSelection);

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 150);
      }

      if (foundWords.length == targetWords.length) {
        _timer?.cancel();
        isGameComplete = true;
      }
    }
    notifyListeners();
  }

  void resetForNextLevel() {
    currentLevel++;
    timeSeconds = 0;
    attempts = 0;
    foundWords.clear();
    foundCells.clear();
    isGameComplete = false;
    firstTap = null;
    _initializeLevel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
