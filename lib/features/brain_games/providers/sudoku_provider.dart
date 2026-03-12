import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class SudokuCell {
  int value = 0;
  bool isFixed = false;
  bool isConflict = false;
  bool isHinted = false; // NEW: Tracks hint usage for distinct visual feedback
}

class SudokuProvider extends ChangeNotifier {
  final String difficulty;

  late int gridSize;
  late int blockW;
  late int blockH;

  List<List<SudokuCell>> grid = [];
  List<List<int>> _solvedGrid = []; // The perfect answer key

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

    // 1. Fill the first row randomly to ensure every puzzle is unique
    List<int> firstRow = List.generate(gridSize, (i) => i + 1)..shuffle();
    for (int c = 0; c < gridSize; c++) {
      grid[0][c].value = firstRow[c];
    }

    // 2. Solve the rest of the board to guarantee a 100% valid grid
    _solveSudoku(1, 0, grid);

    // 3. Save the perfect solution to the answer key and lock all cells initially
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        _solvedGrid[r][c] = grid[r][c].value;
        grid[r][c].isFixed = true;
      }
    }

    // 4. Dig holes to create the puzzle
    int cellsToRemove =
        difficulty == 'Easy' ? 6 : (difficulty == 'Medium' ? 16 : 40);
    int removed = 0;
    final random = Random();

    // Loop until we remove the exact number of required cells
    while (removed < cellsToRemove) {
      int r = random.nextInt(gridSize);
      int c = random.nextInt(gridSize);

      // If the cell hasn't been emptied yet, empty it and make it editable
      if (grid[r][c].value != 0) {
        grid[r][c].value = 0;
        grid[r][c].isFixed = false; // Cell is now open for user input
        removed++;
      }
    }

    _validateBoard();
    notifyListeners();
  }

  bool _solveSudoku(int row, int col, List<List<SudokuCell>> targetGrid) {
    if (row == gridSize) return true; // Reached the end successfully

    int nextRow = col == gridSize - 1 ? row + 1 : row;
    int nextCol = col == gridSize - 1 ? 0 : col + 1;

    if (targetGrid[row][col].value != 0) {
      return _solveSudoku(nextRow, nextCol, targetGrid);
    }

    // Try numbers in random order for better puzzle variety
    List<int> nums = List.generate(gridSize, (i) => i + 1)..shuffle();
    for (int num in nums) {
      if (_isSafeToPlace(row, col, num, targetGrid)) {
        targetGrid[row][col].value = num;
        if (_solveSudoku(nextRow, nextCol, targetGrid)) return true;
        targetGrid[row][col].value = 0; // Backtrack
      }
    }
    return false;
  }

  bool _isSafeToPlace(
      int row, int col, int num, List<List<SudokuCell>> targetGrid) {
    // Check row and column
    for (int x = 0; x < gridSize; x++) {
      if (targetGrid[row][x].value == num) return false;
      if (targetGrid[x][col].value == num) return false;
    }
    // Check block
    int startRow = row - (row % blockH);
    int startCol = col - (col % blockW);
    for (int i = 0; i < blockH; i++) {
      for (int j = 0; j < blockW; j++) {
        if (targetGrid[startRow + i][startCol + j].value == num) return false;
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

    // Prevent overriding fixed cells or hinted cells
    if (grid[selectedRow!][selectedCol!].isFixed) return;

    grid[selectedRow!][selectedCol!].value = num;
    _validateBoard();
    _checkWinCondition();
    notifyListeners();
  }

  void eraseCell() {
    if (selectedRow == null || selectedCol == null || isGameComplete) return;

    // Prevent erasing fixed cells or hinted cells
    if (grid[selectedRow!][selectedCol!].isFixed) return;

    grid[selectedRow!][selectedCol!].value = 0;
    _validateBoard();
    notifyListeners();
  }

  void useHint() {
    if (isGameComplete) return;

    // 1. If the user has a specific editable cell selected that is empty or wrong, hint that exact cell.
    if (selectedRow != null && selectedCol != null) {
      int r = selectedRow!;
      int c = selectedCol!;
      if (!grid[r][c].isFixed && grid[r][c].value != _solvedGrid[r][c]) {
        _applyHint(r, c);
        return;
      }
    }

    // 2. Otherwise, find the first available empty or incorrect cell on the board.
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (!grid[r][c].isFixed && grid[r][c].value != _solvedGrid[r][c]) {
          _applyHint(r, c);
          return;
        }
      }
    }
  }

  void _applyHint(int r, int c) {
    grid[r][c].value = _solvedGrid[r][c];
    grid[r][c].isFixed = true; // Lock it so they don't accidentally erase it
    grid[r][c].isHinted = true; // Mark as hinted for UI coloring
    hintsUsed++;
    selectedRow = r;
    selectedCol = c;

    _validateBoard();
    _checkWinCondition();
    notifyListeners();
  }

  void _validateBoard() {
    // Reset all conflicts
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        grid[r][c].isConflict = false;
      }
    }

    // Safely identify all overlapping numbers
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        int val = grid[r][c].value;
        if (val == 0) continue;

        // Check row
        for (int x = 0; x < gridSize; x++) {
          if (x != c && grid[r][x].value == val) {
            grid[r][c].isConflict = true;
            grid[r][x].isConflict = true;
          }
        }
        // Check column
        for (int x = 0; x < gridSize; x++) {
          if (x != r && grid[x][c].value == val) {
            grid[r][c].isConflict = true;
            grid[x][c].isConflict = true;
          }
        }
        // Check sub-block
        int startRow = r - (r % blockH);
        int startCol = c - (c % blockW);
        for (int i = 0; i < blockH; i++) {
          for (int j = 0; j < blockW; j++) {
            int br = startRow + i;
            int bc = startCol + j;
            if ((br != r || bc != c) && grid[br][bc].value == val) {
              grid[r][c].isConflict = true;
              grid[br][bc].isConflict = true;
            }
          }
        }
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
