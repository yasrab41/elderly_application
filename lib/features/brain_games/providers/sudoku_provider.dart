import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class SudokuCell {
  int value = 0;
  bool isFixed = false;
  bool isConflict = false;
}

class SudokuProvider extends ChangeNotifier {
  final String difficulty;

  late int gridSize;
  late int blockW;
  late int blockH;

  List<List<SudokuCell>> grid = [];
  List<List<int>> _solvedGrid = []; // Kept secret for hints

  int? selectedRow;
  int? selectedCol;

  int timeSeconds = 0;
  int currentLevel = 1;
  int hintsUsed = 0;
  bool isGameComplete = false;
  Timer? _timer;

  SudokuProvider({required this.difficulty}) {
    _initializeLevel();
  }

  void _initializeLevel() {
    _setupDifficultyParameters();
    _generatePuzzle();
    startTimer();
  }

  void _setupDifficultyParameters() {
    // Dynamic sizing based on elderly accessibility
    switch (difficulty) {
      case 'Easy':
        gridSize = 4;
        blockW = 2;
        blockH = 2; // 4x4
        break;
      case 'Medium':
        gridSize = 6;
        blockW = 3;
        blockH = 2; // 6x6
        break;
      case 'Hard':
        gridSize = 9;
        blockW = 3;
        blockH = 3; // 9x9
        break;
      default:
        gridSize = 4;
        blockW = 2;
        blockH = 2;
    }
  }

  void _generatePuzzle() {
    grid = List.generate(
        gridSize, (_) => List.generate(gridSize, (_) => SudokuCell()));
    _solvedGrid = List.generate(gridSize, (_) => List.filled(gridSize, 0));

    _fillDiagonalBlocks();
    _solveSudoku(0, 0, grid);

    // Save the solved state for the Hint feature
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        _solvedGrid[r][c] = grid[r][c].value;
        grid[r][c].isFixed = true; // Temporarily fix all
      }
    }

    // Remove cells based on difficulty
    int cellsToRemove =
        difficulty == 'Easy' ? 6 : (difficulty == 'Medium' ? 16 : 40);
    int removed = 0;
    final random = Random();

    while (removed < cellsToRemove) {
      int r = random.nextInt(gridSize);
      int c = random.nextInt(gridSize);
      if (grid[r][c].value != 0) {
        grid[r][c].value = 0;
        grid[r][c].isFixed = false;
        removed++;
      }
    }
    notifyListeners();
  }

  bool _fillDiagonalBlocks() {
    for (int i = 0; i < gridSize; i += blockW) {
      int hMultiplier = (i ~/ blockW) * blockH;
      _fillBlock(hMultiplier, i);
    }
    return true;
  }

  void _fillBlock(int rowStart, int colStart) {
    int num;
    final random = Random();
    for (int i = 0; i < blockH; i++) {
      for (int j = 0; j < blockW; j++) {
        do {
          num = random.nextInt(gridSize) + 1;
        } while (!_isSafeInBlock(rowStart, colStart, num));
        grid[rowStart + i][colStart + j].value = num;
      }
    }
  }

  bool _isSafeInBlock(int rowStart, int colStart, int num) {
    for (int i = 0; i < blockH; i++) {
      for (int j = 0; j < blockW; j++) {
        if (grid[rowStart + i][colStart + j].value == num) return false;
      }
    }
    return true;
  }

  bool _solveSudoku(int row, int col, List<List<SudokuCell>> targetGrid) {
    if (row == gridSize - 1 && col == gridSize) return true;
    if (col == gridSize) {
      row++;
      col = 0;
    }
    if (targetGrid[row][col].value != 0)
      return _solveSudoku(row, col + 1, targetGrid);

    for (int num = 1; num <= gridSize; num++) {
      if (_isSafeToPlace(row, col, num, targetGrid)) {
        targetGrid[row][col].value = num;
        if (_solveSudoku(row, col + 1, targetGrid)) return true;
        targetGrid[row][col].value = 0;
      }
    }
    return false;
  }

  bool _isSafeToPlace(
      int row, int col, int num, List<List<SudokuCell>> targetGrid) {
    for (int x = 0; x < gridSize; x++) {
      if (targetGrid[row][x].value == num) return false;
      if (targetGrid[x][col].value == num) return false;
    }
    int startRow = row - (row % blockH);
    int startCol = col - (col % blockW);
    for (int i = 0; i < blockH; i++) {
      for (int j = 0; j < blockW; j++) {
        if (targetGrid[i + startRow][j + startCol].value == num) return false;
      }
    }
    return true;
  }

  void selectCell(int r, int c) {
    if (isGameComplete) return;
    selectedRow = r;
    selectedCol = c;
    notifyListeners();
  }

  void inputNumber(int num) {
    if (selectedRow == null || selectedCol == null || isGameComplete) return;
    if (grid[selectedRow!][selectedCol!].isFixed) return;

    grid[selectedRow!][selectedCol!].value = num;
    _validateBoard();
    _checkWinCondition();
    notifyListeners();
  }

  void eraseCell() {
    if (selectedRow == null || selectedCol == null || isGameComplete) return;
    if (grid[selectedRow!][selectedCol!].isFixed) return;

    grid[selectedRow!][selectedCol!].value = 0;
    _validateBoard();
    notifyListeners();
  }

  void useHint() {
    if (isGameComplete) return;

    // Find an empty or incorrect cell
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (!grid[r][c].isFixed && grid[r][c].value != _solvedGrid[r][c]) {
          grid[r][c].value = _solvedGrid[r][c];
          grid[r][c].isFixed = true; // Lock the hinted cell
          hintsUsed++;
          selectedRow = r;
          selectedCol = c;
          _validateBoard();
          _checkWinCondition();
          notifyListeners();
          return;
        }
      }
    }
  }

  void _validateBoard() {
    // Reset conflicts
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        grid[r][c].isConflict = false;
      }
    }
    // Check for duplicates
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        int val = grid[r][c].value;
        if (val == 0) continue;

        // Temporarily clear to check safety
        grid[r][c].value = 0;
        if (!_isSafeToPlace(r, c, val, grid)) {
          grid[r][c].isConflict = true;
        }
        grid[r][c].value = val;
      }
    }
  }

  void _checkWinCondition() async {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c].value == 0 || grid[r][c].isConflict) return;
      }
    }
    _timer?.cancel();
    isGameComplete = true;
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeSeconds++;
      notifyListeners();
    });
  }

  void resetForNextLevel() {
    currentLevel++;
    timeSeconds = 0;
    hintsUsed = 0;
    isGameComplete = false;
    selectedRow = null;
    selectedCol = null;
    _initializeLevel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
