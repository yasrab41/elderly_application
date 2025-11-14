import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/fitness/providers/fitness_provider.dart';
import 'package:elderly_prototype_app/features/fitness/widgets/filter_chips.dart';
import 'package:elderly_prototype_app/features/fitness/widgets/exercise_list_item.dart';
import 'package:elderly_prototype_app/features/fitness/widgets/progress_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FitnessScreen extends ConsumerWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the *main* provider to get the full list for the progress card
    final allExercisesAsync = ref.watch(fitnessProvider);

    // Watch the *filtered* provider for the list view
    final filteredExercisesAsync = ref.watch(filteredFitnessListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.fitnessTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(fitnessProvider.notifier).loadData(),
        child: Column(
          children: [
            // 1. Progress Card
            allExercisesAsync.when(
              data: (allExercises) => ProgressCard(exercises: allExercises),
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading progress: $e'),
              ),
            ),

            // 2. Filter Chips
            const FilterChips(),
            const SizedBox(height: 8),

            // 3. Exercise List
            Expanded(
              child: filteredExercisesAsync.when(
                data: (exercises) {
                  if (exercises.isEmpty) {
                    return const Center(
                        child: Text('No exercises found for this category.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80), // For nav bar
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      return ExerciseListItem(
                        exerciseWithProgress: exercises[index],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) =>
                    Center(child: Text('Error loading exercises: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
