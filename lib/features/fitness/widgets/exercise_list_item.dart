import 'dart:async';
import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:elderly_prototype_app/features/fitness/providers/fitness_provider.dart';
import 'package:elderly_prototype_app/features/fitness/screens/exercise_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//The expandable card widget for each exercise, including the timer and set counters.
class ExerciseListItem extends ConsumerStatefulWidget {
  final ExerciseWithProgress exerciseWithProgress;

  const ExerciseListItem({
    super.key,
    required this.exerciseWithProgress,
  });

  @override
  ConsumerState<ExerciseListItem> createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends ConsumerState<ExerciseListItem> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isRunning = false;

  Exercise get exercise => widget.exerciseWithProgress.exercise;
  ExerciseProgress get progress => widget.exerciseWithProgress.progress;

  @override
  void initState() {
    super.initState();
    // Initialize timer with saved progress (Auto-Save)
    _secondsElapsed = progress.secondsTracked;
  }

  @override
  void dispose() {
    // Ensure timer is cancelled when widget is removed
    _timer?.cancel();
    // Auto-save any running time when disposing
    if (_isRunning) {
      _saveTime();
    }
    super.dispose();
  }

  // Sync state if progress changes from the detail screen while this list item is visible
  @override
  void didUpdateWidget(ExerciseListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exerciseWithProgress.progress.secondsTracked !=
        oldWidget.exerciseWithProgress.progress.secondsTracked) {
      if (!_isRunning) {
        setState(() {
          _secondsElapsed = widget.exerciseWithProgress.progress.secondsTracked;
        });
      }
    }
  }

  void _startTimer() {
    if (_isRunning || progress.isCompleted) return;
    setState(() {
      _isRunning = true;
    });
    // Real-time Tracking
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
      // Save every 5 seconds for robustness (optional: can be adjusted)
      if (_secondsElapsed % 5 == 0) {
        _saveTime();
      }
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
    // Auto-save the paused time
    _saveTime();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsElapsed = 0;
    });
    // Auto-save the reset
    _saveTime();
  }

  // Auto-Save implementation for time
  void _saveTime() {
    ref.read(fitnessProvider.notifier).updateTime(exercise.id, _secondsElapsed);
  }

  void _incrementSet() {
    if (progress.isCompleted) return;
    int newSetCount = progress.setsCompleted + 1;
    // Auto-Save implementation for sets
    ref.read(fitnessProvider.notifier).updateSets(exercise.id, newSetCount);
  }

  void _decrementSet() {
    if (progress.isCompleted || progress.setsCompleted == 0) return;
    int newSetCount = progress.setsCompleted - 1;
    // Auto-Save implementation for sets
    ref.read(fitnessProvider.notifier).updateSets(exercise.id, newSetCount);
  }

  // Individual timers show MM:SS format
  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onViewInstructions() {
    // Pause timer if running when navigating
    if (_isRunning) {
      _pauseTimer();
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(
          exerciseId: exercise.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isCompleted = progress.isCompleted;

    // Auto-stop on Complete: If marked complete elsewhere, stop the timer.
    if (isCompleted && _isRunning) {
      _pauseTimer();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.network(
                  exercise.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                        child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ));
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Difficulty
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            exercise.title,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _DifficultyChip(difficulty: exercise.difficulty),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Tags (Time, Category)
                    Row(
                      children: [
                        _TagChip(
                          icon: Icons.timer_outlined,
                          label:
                              '${exercise.estimatedMinutes} ${AppStrings.minutesShort}',
                        ),
                        const SizedBox(width: 8),
                        _TagChip(
                          icon: _getCategoryIcon(exercise.category),
                          label: exercise.category.name,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Timer Section
                    _buildTimerControl(theme, isCompleted),
                    const SizedBox(height: 16),
                    // Sets Counter Section
                    _buildSetCounter(theme, isCompleted),
                    const SizedBox(height: 16),
                    // View Instructions Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.list_alt),
                        label: const Text(AppStrings.viewInstructions),
                        onPressed: _onViewInstructions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8667E3), // Purple
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Completed Badge (Green banner)
          if (isCompleted)
            Container(
              width: double.infinity,
              color: Colors.green.withOpacity(0.9),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    AppStrings.completedToday,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimerControl(ThemeData theme, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.exerciseTimer,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(_secondsElapsed),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // Start/Pause Button (Blue/Red controls)
                  ElevatedButton(
                    child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    onPressed: isCompleted
                        ? null
                        : (_isRunning ? _pauseTimer : _startTimer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isRunning ? Colors.redAccent : Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reset Button (Gray reset button)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: isCompleted ? null : _resetTimer,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetCounter(ThemeData theme, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.setsCompleted,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              // Decrement Button
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: isCompleted ? null : _decrementSet,
                color: theme.colorScheme.primary,
                iconSize: 30,
              ),
              // Sets Counter Display
              Text(
                '${progress.setsCompleted}',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              // Increment Button
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: isCompleted ? null : _incrementSet,
                color: theme.colorScheme.primary,
                iconSize: 30,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.stretching:
        return Icons.self_improvement;
      case ExerciseCategory.strength:
        return Icons.fitness_center;
      case ExerciseCategory.cardio:
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }
}

// --- Helper Widgets ---
class _DifficultyChip extends StatelessWidget {
  final String difficulty;
  const _DifficultyChip({required this.difficulty});

  Color _getColor() {
    if (difficulty == AppStrings.difficultyEasy) {
      return Colors.green;
    } else if (difficulty == AppStrings.difficultyMedium) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(difficulty),
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
      backgroundColor: _getColor(),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}

class _TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TagChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
