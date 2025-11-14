import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:flutter/material.dart';

class AppStrings {
  static const String appTitle = 'Elderly Care App';
  static const String fitnessTitle = 'Daily Exercises';
  static const String filterAll = 'All';
  static const String exercisesCompleted = 'exercises completed';
  static const String nextWorkoutTitle = 'Next Workout';
  static const String startWorkout = 'Start Workout';
  static const String setsCompleted = 'Sets Completed:';

  // ⭐️ ADDED: Strings for the detail screen
  static const String steps = 'Steps';
  static const String exerciseTimer = 'Exercise Timer';
  static const String markComplete = 'Mark as Complete';
  static const String markIncomplete = 'Mark as Incomplete';
  static const String close = 'Close';
  static const String minutesShort = 'min';
  static const String difficultyEasy = 'Easy';
  static const String difficultyMedium = 'Medium';
  static const String difficultyHard = 'Hard';
}

// --- Mock Exercise Data with more variety ---
final List<ExerciseModel> exercises = [
  // --- STRETCHING (7 exercises) ---
  ExerciseModel(
    id: 'S1',
    title: 'Gentle Neck Circles',
    description: 'Slow, controlled circles to relax neck and shoulders.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 3),
    difficultyLevel: 1,
    instructions:
        'Start slowly, clockwise then counter-clockwise. Do not rush or force movement.',
    imageUrl: 'https://placehold.co/600x400/F7D9EA/C86DD7?text=Neck+Stretch',
  ),
  ExerciseModel(
    id: 'S2',
    title: 'Shoulder Rolls',
    description: 'Roll shoulders backward and forward to release tension.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 2),
    difficultyLevel: 1,
    instructions:
        'Inhale as you lift shoulders, exhale as you relax them down. 10 reps each direction.',
    imageUrl: 'https://placehold.co/600x400/F7D9EA/C86DD7?text=Shoulder+Rolls',
  ),
  ExerciseModel(
    id: 'S3',
    title: 'Seated Torso Twist',
    description:
        'Gentle twist to improve spinal mobility. Use a chair for support.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 4),
    difficultyLevel: 2,
    instructions:
        'Sit up straight, gently twist to the left, holding for 30 seconds. Repeat right.',
    imageUrl: 'https://placehold.co/600x400/F7D9EA/C86DD7?text=Torso+Twist',
  ),
  ExerciseModel(
    id: 'S4',
    title: 'Wrist and Finger Stretch',
    description: 'Stretching for hands and wrists to maintain dexterity.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 2),
    difficultyLevel: 1,
    instructions:
        'Extend arms, gently pull fingers back towards body. Hold for 15 seconds.',
    imageUrl: 'https://placehold.co/600x400/F7D9EA/C86DD7?text=Wrist+Stretch',
  ),
  ExerciseModel(
    id: 'S5',
    title: 'Ankle Rotations',
    description: 'Improves ankle flexibility and circulation.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 3),
    difficultyLevel: 1,
    instructions:
        'Sit comfortably. Rotate each ankle clockwise and counter-clockwise 15 times.',
    imageUrl: 'https://placehold.co/600x400/F7D9EA/C86DD7?text=Ankle+Rotations',
  ),
  ExerciseModel(
    id: 'S6',
    title: 'Standing Quad Stretch (Assisted)',
    description: 'Stretching the front of the thighs with chair assistance.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 5),
    difficultyLevel: 3,
    instructions:
        'Hold a chair. Bend one knee and gently pull heel toward glutes. Hold 20 seconds per side.',
    imageUrl: 'https://placehold.co/600x400/F7D9EA/C86DD7?text=Quad+Stretch',
  ),
  ExerciseModel(
    id: 'S7',
    title: 'Seated Hamstring Stretch',
    description: 'Reaches the back of the legs while seated.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 4),
    difficultyLevel: 2,
    instructions:
        'Sit on the edge of a chair, one leg extended. Lean forward slightly from the hips until a stretch is felt.',
    imageUrl:
        'https://placehold.co/600x400/F7D9EA/C86DD7?text=Hamstring+Stretch',
  ),

  // --- STRENGTH (7 exercises) ---
  ExerciseModel(
    id: 'T1',
    title: 'Chair Squats',
    description:
        'Sitting down and standing up without using hands for leg strength.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 5),
    difficultyLevel: 2,
    instructions:
        'Start seated. Lean forward slightly and push through your feet to stand up. Slowly return to the chair. Repeat 10 times.',
    imageUrl: 'https://placehold.co/600x400/D7E9CD/5CB85C?text=Chair+Squats',
  ),
  ExerciseModel(
    id: 'T2',
    title: 'Wall Push-ups',
    description: 'Upper body and chest strengthening using a wall.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 4),
    difficultyLevel: 2,
    instructions:
        'Stand facing a wall, hands slightly wider than shoulders. Slowly bend elbows to lower chest toward wall, then push back. 12 repetitions.',
    imageUrl: 'https://placehold.co/600x400/D7E9CD/5CB85C?text=Wall+Push-ups',
  ),
  ExerciseModel(
    id: 'T3',
    title: 'Bicep Curls (with light weights)',
    description: 'Building arm and grip strength.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 6),
    difficultyLevel: 3,
    instructions:
        'Use light dumbbells or water bottles. Keep elbows close to sides. Curl slowly up and down. 3 sets of 10.',
    imageUrl: 'https://placehold.co/600x400/D7E9CD/5CB85C?text=Bicep+Curls',
  ),
  ExerciseModel(
    id: 'T4',
    title: 'Standing Leg Lifts (Side)',
    description: 'Strengthening hip abductors for better balance.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 4),
    difficultyLevel: 2,
    instructions:
        'Hold a sturdy chair. Keep leg straight and lift it out to the side slowly. Lower slowly. 15 reps per leg.',
    imageUrl: 'https://placehold.co/600x400/D7E9CD/5CB85C?text=Leg+Lifts',
  ),
  ExerciseModel(
    id: 'T5',
    title: 'Calf Raises (Assisted)',
    description: 'Strengthening calf muscles to aid walking.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 3),
    difficultyLevel: 1,
    instructions:
        'Hold onto a stable surface. Slowly lift heels, rising onto the balls of your feet. Lower slowly. 20 repetitions.',
    imageUrl: 'https://placehold.co/600x400/D7E9CD/5CB85C?text=Calf+Raises',
  ),
  ExerciseModel(
    id: 'T6',
    title: 'Plank (Modified, on Knees)',
    description: 'Core stabilization and strength.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 3),
    difficultyLevel: 4,
    instructions:
        'Start on hands and knees, then move to forearms. Keep back straight and engage core. Hold for 30 seconds.',
    imageUrl: 'https://placehold.co/600x400/D7E9CD/5CB85C?text=Modified+Plank',
  ),
  ExerciseModel(
    id: 'T7',
    title: 'Triceps Extension (Seated)',
    description: 'Toning and strengthening the back of the arms.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 5),
    difficultyLevel: 3,
    instructions:
        'Use a light weight. Raise arm overhead, then bend elbow to lower weight behind head. Extend back up. 2 sets of 10 per arm.',
    imageUrl:
        'https://placehold.co/600x400/D7E9CD/5CB85C?text=Triceps+Extension',
  ),

  // --- CARDIO (6 exercises) ---
  ExerciseModel(
    id: 'C1',
    title: 'Marching in Place',
    description: 'Low-impact cardiovascular exercise.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 10),
    difficultyLevel: 1,
    instructions:
        'Lift knees hip-height, swing arms naturally. Maintain a steady rhythm.',
    imageUrl: 'https://placehold.co/600x400/D9F3F7/337AB7?text=Marching',
  ),
  ExerciseModel(
    id: 'C2',
    title: 'Seated Punching',
    description: 'Engages core and upper body for a quick cardio burst.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 5),
    difficultyLevel: 2,
    instructions:
        'Sit upright. Alternate punching arms straight out in front of you. Keep punches light and fast.',
    imageUrl: 'https://placehold.co/600x400/D9F3F7/337AB7?text=Seated+Punching',
  ),
  ExerciseModel(
    id: 'C3',
    title: 'Stepping Side-to-Side',
    description: 'Lateral movement to improve agility and heart rate.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 8),
    difficultyLevel: 2,
    instructions:
        'Take a step to the right, bring the left foot to meet it. Repeat left. Keep moving briskly.',
    imageUrl: 'https://placehold.co/600x400/D9F3F7/337AB7?text=Side+Steps',
  ),
  ExerciseModel(
    id: 'C4',
    title: 'Low-Impact Jumping Jacks (Step Jacks)',
    description: 'Modified full-body cardio with no jumping.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 7),
    difficultyLevel: 3,
    instructions:
        'Step one foot out while raising arms overhead. Return to center. Alternate sides quickly.',
    imageUrl: 'https://placehold.co/600x400/D9F3F7/337AB7?text=Step+Jacks',
  ),
  ExerciseModel(
    id: 'C5',
    title: 'Stair Climbing',
    description: 'Excellent lower-body cardio and strength builder.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 15),
    difficultyLevel: 4,
    instructions:
        'Use a handrail for safety. Step up and down one step repeatedly. Take breaks as needed.',
    imageUrl: 'https://placehold.co/600x400/D9F3F7/337AB7?text=Stair+Climbing',
  ),
  ExerciseModel(
    id: 'C6',
    title: 'Heel Digs',
    description: 'A low-impact alternative to running or marching.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 6),
    difficultyLevel: 1,
    instructions:
        'Alternate tapping your heels out in front of you while swinging your arms. Maintain a steady pace.',
    imageUrl: 'https://placehold.co/600x400/D9F3F7/337AB7?text=Heel+Digs',
  ),
];
