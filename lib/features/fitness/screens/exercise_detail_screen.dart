import 'dart:async';
import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:elderly_prototype_app/features/fitness/providers/fitness_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ⭐️ NEW: StateProvider for the timer value in seconds
final _timerValueProvider = StateProvider.autoDispose<int>((ref) => 0);

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
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // Initialize state from the provider
    final data = ref
        .read(fitnessProvider)
        .value!
        .firstWhere((e) => e.exercise.id == widget.exerciseId);

    // Initialize the Riverpod timer value from the persistent progress data
    ref.read(_timerValueProvider.notifier).state = data.progress.secondsTracked;
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

  void _startTimer(ExerciseProgress progress) {
    // Read current value from the provider
    int currentSeconds = ref.read(_timerValueProvider);

    if (_isRunning || progress.isCompleted) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Update the Riverpod state provider every second
      currentSeconds++;
      ref.read(_timerValueProvider.notifier).state = currentSeconds;

      // Save every 5 seconds for robustness
      if (currentSeconds % 5 == 0) {
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
    });
    // Reset the Riverpod state provider to 0
    ref.read(_timerValueProvider.notifier).state = 0;
    // Auto-save the reset
    _saveTime();
  }

  void _saveTime() {
    // Read the latest value from the provider before saving
    final totalSeconds = ref.read(_timerValueProvider);
    ref
        .read(fitnessProvider.notifier)
        .updateTime(widget.exerciseId, totalSeconds);
  }

  void _incrementSet(ExerciseProgress progress) {
    if (progress.isCompleted) return;
    int newSetCount = progress.timesCompleted + 1;
    ref
        .read(fitnessProvider.notifier)
        .updateSets(widget.exerciseId, newSetCount);
  }

  void _decrementSet(ExerciseProgress progress) {
    if (progress.isCompleted || progress.timesCompleted == 0) return;
    int newSetCount = progress.timesCompleted - 1;
    ref
        .read(fitnessProvider.notifier)
        .updateSets(widget.exerciseId, newSetCount);
  }

  /// ⭐️ FIX: Toggles completion state and handles timer/UI updates.
  void _markComplete() async {
    // 1. Get current time tracked from the Riverpod state provider
    final currentSeconds = ref.read(_timerValueProvider);

    // If running, pause and save time first
    if (_isRunning) {
      _pauseTimer();
    }

    // 2. Perform the toggle and save the new state (including time)
    await ref.read(fitnessProvider.notifier).toggleComplete(
          widget.exerciseId,
          currentSeconds,
        );

    // 3. Update local state and timer based on the new completion status
    // ⭐️⭐️ THIS IS THE LINE FROM YOUR SCREENSHOT ⭐️⭐️
    final updatedProgress = ref
        .read(fitnessProvider.notifier)
        .getExerciseProgress(widget.exerciseId);

    if (updatedProgress.isCompleted) {
      // If marked complete, stop the timer
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    } else {
      // If marked incomplete, reset the local timer value in the UI to 0
      ref.read(_timerValueProvider.notifier).state = 0;
    }

    // 4. Update the screen state to trigger rebuilds (like the button color)
    setState(() {});
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watch the persistent data provider
    final asyncData = ref.watch(fitnessProvider);
    // Watch the local timer value provider
    final secondsElapsed = ref.watch(_timerValueProvider);

    return asyncData.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text("Error: $e"))),
      data: (data) {
        final exerciseWithProgress = data.firstWhere(
          (e) => e.exercise.id == widget.exerciseId,
          orElse: () => data.first,
        );

        final exercise = exerciseWithProgress.exercise;
        final progress = exerciseWithProgress.progress;
        final bool isCompleted = progress.isCompleted;

        // Auto-stop on Complete: If marked complete, stop the local running timer
        if (isCompleted && _isRunning) {
          // Use addPostFrameCallback to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _pauseTimer();
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(exercise.title),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⭐️ NEW: Exercise Image ⭐️
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      exercise.imageUrl, // e.g. "assets/images/squat.png"
                      fit: BoxFit.cover,
                      height: 250,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
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
                                  exercise.title,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              // ⭐️ FIX: Using correct difficulty property
                              _DifficultyChip(
                                  difficulty: exercise.difficultyLevel),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            // ⭐️ FIX: Using correct duration property
                            '${exercise.duration.inMinutes} ${AppStrings.minutesShort} • ${exercise.category.name}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Timer Controls
                          // Pass the secondsElapsed from the provider
                          _buildTimerControl(
                              theme, isCompleted, progress, secondsElapsed),
                          const SizedBox(height: 16),

                          // Sets Counter
                          _buildSetCounter(theme, progress),
                          const SizedBox(height: 24),

                          // Steps Instructions
                          Text(
                            AppStrings.steps,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildStepsList(
                              theme,
                              exercise
                                  .instructions), // ⭐️ FIX: Using correct property
                          const SizedBox(height: 24),

                          // Action Buttons
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(isCompleted
                                  ? Icons.cancel
                                  : Icons.check_circle),
                              label: Text(isCompleted
                                  ? AppStrings.markIncomplete
                                  : AppStrings.markComplete),
                              // ⭐️ FIX: Call the new _markComplete logic
                              onPressed: _markComplete,
                              style: ElevatedButton.styleFrom(
                                // ⭐️ FIX: Toggling color based on completion state
                                backgroundColor: isCompleted
                                    ? theme.colorScheme.onSurface
                                        .withOpacity(0.4)
                                    : theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                foregroundColor: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), // Padding for bottom nav
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepsList(ThemeData theme, String instructions) {
    // ⭐️ FIX: Split instructions string into a list of steps
    final List<String> steps =
        instructions.split('. ').where((s) => s.isNotEmpty).toList();

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
                    steps[index].endsWith('.')
                        ? steps[index]
                        : '${steps[index]}.', // Ensure punctuation
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
  Widget _buildTimerControl(ThemeData theme, bool isCompleted,
      ExerciseProgress progress, int secondsElapsed) {
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
                _formatTime(
                    secondsElapsed), // ⭐️ FIX: Use secondsElapsed from provider
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
                        : (_isRunning
                            ? _pauseTimer
                            : () => _startTimer(progress)),
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
  Widget _buildSetCounter(ThemeData theme, ExerciseProgress progress) {
    final bool isCompleted = progress.isCompleted;
    final int setCount = progress.timesCompleted;

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
                onPressed: isCompleted ? null : () => _decrementSet(progress),
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
                onPressed: isCompleted ? null : () => _incrementSet(progress),
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
  final int difficulty; // ⭐️ FIX: Use int
  const _DifficultyChip({required this.difficulty});

  String _getText() {
    if (difficulty == 1) {
      return AppStrings.difficultyEasy;
    } else if (difficulty == 2) {
      return AppStrings.difficultyMedium;
    } else {
      return AppStrings.difficultyHard;
    }
  }

  Color _getColor() {
    if (difficulty == 1) {
      return Colors.green;
    } else if (difficulty == 2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_getText()),
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
      backgroundColor: _getColor(),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}
