import 'dart:async';
import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:elderly_prototype_app/features/fitness/providers/fitness_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final String exerciseId;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isRunning = false;

  late ExerciseWithProgress _data;

  @override
  void initState() {
    super.initState();
    // Initialize state from the provider
    _data = ref
        .read(fitnessProvider)
        .value!
        .firstWhere((e) => e.exercise.id == widget.exerciseId);

    _secondsElapsed = _data.progress.secondsTracked;
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Auto-save any running time when disposing
    if (_isRunning) {
      _saveTime();
    }
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning || _data.progress.isCompleted) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
      // Save every 5 seconds for robustness
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

  void _saveTime() {
    ref
        .read(fitnessProvider.notifier)
        .updateTime(_data.exercise.id, _secondsElapsed);
  }

  void _incrementSet() {
    if (_data.progress.isCompleted) return;
    int newSetCount = _data.progress.setsCompleted + 1;
    ref
        .read(fitnessProvider.notifier)
        .updateSets(_data.exercise.id, newSetCount);
  }

  void _decrementSet() {
    if (_data.progress.isCompleted || _data.progress.setsCompleted == 0) return;
    int newSetCount = _data.progress.setsCompleted - 1;
    ref
        .read(fitnessProvider.notifier)
        .updateSets(_data.exercise.id, newSetCount);
  }

  void _toggleComplete() {
    // If running, pause and save time first
    if (_isRunning) {
      _pauseTimer();
    }
    // Toggle completion state (Auto-stop on Complete is handled in ListItem, but good to handle here too)
    ref
        .read(fitnessProvider.notifier)
        .toggleComplete(_data.exercise.id, _secondsElapsed);
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Listen to the provider to get real-time updates for sets and completion
    _data = ref
        .watch(fitnessProvider)
        .value!
        .firstWhere((e) => e.exercise.id == widget.exerciseId);

    final exercise = _data.exercise;
    final progress = _data.progress;
    final bool isCompleted = progress.isCompleted;

    // Sync local timer if it was changed externally and we're not running
    if (!_isRunning && _secondsElapsed != progress.secondsTracked) {
      _secondsElapsed = progress.secondsTracked;
    }

    // Auto-stop on Complete: If marked complete, stop the local running timer
    if (isCompleted && _isRunning) {
      _pauseTimer();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            child: Padding(
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
                          'Instructions',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _DifficultyChip(difficulty: exercise.difficulty),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Timer Controls
                  _buildTimerControl(theme, isCompleted),
                  const SizedBox(height: 16),

                  // Sets Counter
                  _buildSetCounter(theme, isCompleted, progress.setsCompleted),
                  const SizedBox(height: 24),

                  // Steps Instructions
                  Text(
                    AppStrings.steps,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStepsList(theme, exercise.steps),
                  const SizedBox(height: 24),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon:
                          Icon(isCompleted ? Icons.cancel : Icons.check_circle),
                      label: Text(isCompleted
                          ? AppStrings.markIncomplete
                          : AppStrings.markComplete),
                      onPressed: _toggleComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isCompleted ? Colors.grey : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      child: const Text(AppStrings.close),
                      onPressed: () {
                        // Pause timer if running when closing
                        if (_isRunning) {
                          _pauseTimer();
                        }
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsList(ThemeData theme, List<String> steps) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF), // Light purple
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF8667E3),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    steps[index],
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Timer control helper
  Widget _buildTimerControl(ThemeData theme, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
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

  // Set counter helper
  Widget _buildSetCounter(ThemeData theme, bool isCompleted, int setCount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
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
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: isCompleted ? null : _decrementSet,
                color: theme.colorScheme.primary,
                iconSize: 30,
              ),
              Text(
                '$setCount',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
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
}

// Helper chip
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
