import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:elderly_prototype_app/features/fitness/providers/fitness_provider.dart';
import 'package:elderly_prototype_app/features/fitness/screens/exercise_detail_screen.dart';
import 'package:elderly_prototype_app/features/fitness/widgets/category_card.dart';
import 'package:elderly_prototype_app/features/fitness/widgets/exercise_list_item.dart';
import 'package:elderly_prototype_app/features/fitness/widgets/filter_chips.dart';
import 'package:elderly_prototype_app/features/fitness/widgets/next_workout_card.dart';
import 'package:elderly_prototype_app/features/fitness/widgets/total_progress_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FitnessScreen extends ConsumerWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the main provider which contains ALL exercises and progress
    final allExercisesAsync = ref.watch(fitnessProvider);

    // Watch the random next workout provider
    final nextWorkout = ref.watch(randomNextWorkoutProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. App Bar Area
          _buildSliverAppBar(context, ref),

          // 2. Content
          allExercisesAsync.when(
            data: (allExercises) {
              return SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // --- BODY ---
                    const SizedBox(height: 20),

                    // Total Time/Progress Card (Uses the totalTime and progress from the provider)
                    TotalProgressCard(allExercises: allExercises),

                    const SizedBox(height: 30),

                    // "Your program"
                    _buildSectionHeader(context, 'Your Program'),
                    // Next Workout Card
                    NextWorkoutCard(
                      exerciseWithProgress: nextWorkout,
                      onStart: () {
                        if (nextWorkout != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseDetailScreen(
                                exerciseId: nextWorkout.exercise.id,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 30),

                    // "Area of Focus"
                    _buildSectionHeader(context, 'Area of Focus'),
                    // Category Cards Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          CategoryCard(
                            category: ExerciseCategory.stretching,
                            color: const Color(0xFFF7D9EA),
                            iconColor: const Color(0xFFC86DD7),
                            onTap: () => _navigateToCategoryList(
                                context, ExerciseCategory.stretching),
                          ),
                          CategoryCard(
                            category: ExerciseCategory.strength,
                            color: const Color(0xFFD7E9CD),
                            iconColor: const Color(0xFF5CB85C),
                            onTap: () => _navigateToCategoryList(
                                context, ExerciseCategory.strength),
                          ),
                          CategoryCard(
                            category: ExerciseCategory.cardio,
                            color: const Color(0xFFD9F3F7),
                            iconColor: const Color(0xFF337AB7),
                            onTap: () => _navigateToCategoryList(
                                context, ExerciseCategory.cardio),
                          ),
                          CategoryCard(
                            category: ExerciseCategory.all,
                            titleOverride: 'View All',
                            color: const Color(0xFFEAD9F7),
                            icon: Icons.list_alt,
                            iconColor: const Color(0xFF8667E3),
                            onTap: () => _navigateToCategoryList(
                                context, ExerciseCategory.all),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80), // Padding for bottom nav
                  ],
                ),
              );
            },
            loading: () => SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary))),
            error: (e, s) => SliverFillRemaining(
                child: Center(child: Text('Error loading data: $e'))),
          ),
        ],
      ),
    );
  }

  // Helper to build the section titles
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  // Helper to navigate to the detailed list view for a category
  void _navigateToCategoryList(
      BuildContext context, ExerciseCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryListViewScreen(
          initialCategory: category,
        ),
      ),
    );
  }

  // Custom AppBar to match the "Training" header design
  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref) {
    // The total time display logic is now inside TotalProgressCard.
    // We only need the SliverAppBar for visual purposes.
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF8B4513).withOpacity(0.8), // Earthy Brown
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
        title: Text(
          AppStrings.fitnessTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background color/gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF48352A), // Dark brown
                    const Color(0xFF8B4513), // Medium brown
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Custom shape overlay (optional, for aesthetics)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// Category List View Screen
// --------------------------------------------------------------------------

class CategoryListViewScreen extends ConsumerStatefulWidget {
  final ExerciseCategory initialCategory;

  const CategoryListViewScreen({
    super.key,
    required this.initialCategory,
  });

  @override
  ConsumerState<CategoryListViewScreen> createState() =>
      _CategoryListViewScreenState();
}

class _CategoryListViewScreenState
    extends ConsumerState<CategoryListViewScreen> {
  @override
  void initState() {
    super.initState();
    // FIX: Defer the state update until after the current frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fitnessCategoryFilterProvider.notifier).state =
          widget.initialCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the filtered list based on the state set above
    final filteredExercisesAsync = ref.watch(filteredFitnessListProvider);
    final selectedCategory = ref.watch(fitnessCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategory.name == AppStrings.filterAll
            ? 'All Exercises'
            : '${selectedCategory.name} Focus'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips (Allow changing the filter from this view too)
          const FilterChips(),
          const SizedBox(height: 8),

          // Progress Summary (Small version of the progress card)
          ref.watch(fitnessProvider).when(
                data: (allExercises) {
                  final totalExercises = allExercises.length;
                  final completedExercises =
                      allExercises.where((e) => e.progress.isCompleted).length;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      '$completedExercises of $totalExercises ${AppStrings.exercisesCompleted} today.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),
          const Divider(indent: 16, endIndent: 16),

          // Exercise List
          Expanded(
            child: filteredExercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                      child:
                          Text('No ${selectedCategory.name} exercises found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    return ExerciseListItem(
                      exerciseWithProgress: exercises[index],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error loading list: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
