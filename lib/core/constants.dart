import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';

class AppStrings {
  static const String appTitle = 'Elderly Care App';
  static const String fitnessTitle = 'Daily Exercises';
  static const String filterAll = 'All';
  static const String exercisesCompleted = 'exercises completed';
  static const String nextWorkoutTitle = 'Next Workout';
  static const String startWorkout = 'Start Workout';
  static const String setsCompleted = 'Sets Completed:';

  // --- Start Emergency / SOS Feature ---
  static const String sosTitle = 'Send Emergency Alert';
  static const String sosCancelButton = 'I AM SAFE / CANCEL';
  static const String sosSendingAlert = 'Sending Alert in...';

  // Settings & Contacts
  static const String sosSettingsTitle = 'Emergency Contacts';
  static const String sosSettingsSubtitle = 'Manage who to call in emergency';
  static const String addContactTitle = 'Add New Contact';
  static const String editContactTitle = 'Edit Contact';
  static const String contactNameHint = 'Contact Name';
  static const String contactPhoneHint = 'Phone Number (e.g., +90555...)';
  static const String isPrimaryLabel = 'Set as Primary Contact';
  static const String isPrimaryHint =
      'This person will be called automatically.';
  static const String saveLabel = 'Save Contact';
  static const String deleteLabel = 'Delete';

  // Messages
  static const String emergencyAlertMessage =
      'HELP! \nI have an emergency. \nMy location: ';
  static const String validationName = 'Please enter a name';
  static const String validationPhone = 'Please enter a phone number';
  static const String noContacts = 'No emergency contacts added yet.';
  //--- Ends Emergency / SOS Feature ---

  //--- Start of Exercise Feature ---
  // ⭐️ ADDED: Strings for the detail screen of Exercise
  static const String steps = 'Steps';
  static const String exerciseTimer = 'Exercise Timer';
  static const String markComplete = 'Mark as Complete';
  static const String markIncomplete = 'Mark as Incomplete';
  static const String close = 'Close';
  static const String minutesShort = 'min';
  static const String difficultyEasy = 'Easy';
  static const String difficultyMedium = 'Medium';
  static const String difficultyHard = 'Hard';
  //--- End of Exercise Feature ---

  //--- Start of Health Tracking Feature ---
  static const String healthTitle = 'Health Tracking';
  static const String bloodPressure = 'Blood Pressure';
  static const String bloodSugar = 'Blood Sugar';
  static const String weight = 'Weight';
  static const String sleep = 'Sleep';
  static const String heartRate = 'Heart Rate';
// static const String steps = 'Steps';

// Units
  static const String unitBP = 'mmHg';
  static const String unitSugar = 'mg/dL';
  static const String unitWeight = 'kg';
  static const String unitSleep = 'hours';
  static const String unitHeart = 'bpm';
  static const String unitSteps = 'steps';

// Status
  static const String statusNormal = 'Normal';
  static const String statusWarning = 'Attention';
  static const String statusCritical = 'Critical';

// Time Ranges
  static const String week = 'Week';
  static const String month = 'Month';
  static const String year = 'Year';

// Chart & History
  static const String noData = 'No records yet.';
  static const String recentHistory = 'Recent History';
  static const String addRecord = 'Add Record';
  static const String sys = 'Systolic';
  static const String dia = 'Diastolic';
  //--- End of Health Tracking Feature ---

  // --- Start of Water Reminder Feature ---
  static const String waterTitle = 'Water Reminder';
  static const String goalLabel = 'Goal:';
  static const String goalAchieved = '🎉 Great job! Goal achieved!';
  static const String remindersTitle = 'Reminders';
  static const String every = 'Every';
  static const String hoursSuffix = 'hour(s)';
  static const String disabled = 'Disabled';
  static const String changeSettings = 'Change Settings';
  static const String addWaterTitle = 'Add Water';
  static const String noWaterLogged = 'No water logged today';
  static const String todaysWater = "Today's Water";
  static const String settingsTitle = 'Settings';
  static const String remindMeEvery = 'Remind me every:';
  static const String activeHoursTitle = 'Active Hours (No sleep disturbance):';
  static const String vibrationTitle = 'Vibration';
  static const String vibrationSubtitle = 'Vibrate on reminder';
  static const String saveButton = 'Save';
  // --- End of Water Reminder Feature ---

  // --- Start Memory Match Games Feature ---
  static const String brainGamesTitle = 'Brain Games';
  static const String memoryMatchTitle = 'Memory Match';
  static const String memoryMatchDesc =
      'Find the matching pairs to keep your mind sharp.';
  static const String movesCounter = 'Moves:';
  static const String timeCounter = 'Time:';
  static const String pairsFound = 'Pairs Found:';
  static const String wellDone = 'Well Done!';
  static const String gameCompleteMsg = 'You found all the matches!';
  static const String playAgain = 'Play Again';
  static const String quitGame = 'Quit';
  static const String statsTitle = 'Your Progress';
  static const String bestTime = 'Best Time';
  static const String totalGames = 'Total Games Played';
  static const String wordSearchTitle = 'Word Search';
  static const String sudokuTitle = 'Sudoku';
  static const String comingSoon = 'Coming Soon';
  static const String continueGame = 'Continue Next Level';
  static const String level = 'Level';
  static const String totalTimeLabel = 'Total Time Spent:';
  static const String avgTimeLabel = 'Average Time:';
  static const String bestTimeLabel = 'Fastest Win:';
  static const String totalWinsLabel = 'Total Wins:';
  static const String noStatsYet = 'Play a game to see your stats!';
  // --- End Memory match Feature ---

  // --- Start Word Search Feature ---
  static const String wordSearchDesc =
      'Find the hidden words to train your focus.';
  static const String wordsRemaining = 'Words Remaining:';
  static const String wordsFound = 'Words Found:';
  static const String tapFirstTapLast =
      'Tap the first letter, then tap the last letter of a word.';

  // Localized Word Categories (Easy, Medium, Hard)
  static const List<String> easyWords = [
    'CAT',
    'DOG',
    'BIRD',
    'FISH',
    'COW',
    'APPLE',
    'PLUM',
    'PEAR',
    'MILK',
    'TEA',
    'SUN',
    'MOON',
    'STAR',
    'TREE',
    'LEAF',
    'HOME',
    'BED',
    'SOFA',
    'BOOK',
    'PEN'
  ];

  static const List<String> mediumWords = [
    'RABBIT',
    'TURTLE',
    'MONKEY',
    'SPIDER',
    'BANANA',
    'ORANGE',
    'GRAPES',
    'CHERRY',
    'COFFEE',
    'WATER',
    'FLOWER',
    'GARDEN',
    'FOREST',
    'RIVER',
    'WINDOW',
    'MIRROR',
    'FAMILY',
    'DOCTOR',
    'NURSE',
    'HEALTH'
  ];

  static const List<String> hardWords = [
    'ELEPHANT',
    'KANGAROO',
    'CROCODILE',
    'PINEAPPLE',
    'STRAWBERRY',
    'WATERMELON',
    'BREAKFAST',
    'MEDICINE',
    'HOSPITAL',
    'AMBULANCE',
    'MOUNTAIN',
    'WATERFALL',
    'GRANDMOTHER',
    'GRANDFATHER',
    'TELEVISION',
    'NEWSPAPER',
    'FURNITURE'
  ];
  // --- End Word Search Feature ---

  // --- Start Sudoku Game Feature ---
  static const String sudokuDesc =
      'Fill the grid with numbers without repeating them in rows, columns, or blocks.';
  static const String hintsUsed = 'Hints Used:';
  static const String hintButton = 'Hint';
  static const String eraseButton = 'Erase';
  static const String sudokuInstructions =
      'Tap an empty square, then pick a number.';
  // --- End Sudoku Game Feature ---
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
        'Slow, controlled circles to relax neck and shoulders. Start slowly, clockwise then counter-clockwise. Do not rush or force movement.',
    imageUrl: 'assets/images/neck_circles.png',
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
    imageUrl: 'assets/images/shoulder_roll.png',
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
    imageUrl: 'assets/images/seated_torso_twisted.jpg',
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
    imageUrl: 'assets/images/wrist_finger_stretches.jpg',
  ),
  ExerciseModel(
    id: 'S5',
    title: 'Ankle Rotations',
    description: 'Improves ankle flexibility and circulation.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 3),
    difficultyLevel: 1,
    instructions:
        'Sit comfortably. Rotate each ankle clockwise and counterclockwise 15 times. Switch ankles and repeat the same steps.',
    imageUrl: 'assets/images/ankle_rotation.png',
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
    imageUrl: 'assets/images/standing_quads.png',
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
    imageUrl: 'assets/images/seated_hamstring.png',
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
    imageUrl: 'assets/images/chair_squats.png',
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
    imageUrl: 'assets/images/wall_push_ups.png',
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
    imageUrl: 'assets/images/bicep_curls.png',
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
    imageUrl: 'assets/images/standing_leg_lifts.png',
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
    imageUrl: 'assets/images/assisted_calf_raise.png',
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
    imageUrl: 'assets/images/plank_exercise.png',
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
    imageUrl: 'assets/images/triceps_extension.png',
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
        'Stand tall near a chair or wall for support. Slowly lift one knee toward hip height (or comfortable height). Lower the leg gently and switch sides. Swing arms naturally to improve balance and coordination. Maintain a slow, steady rhythm. Repetitions: 20-40 steps total or 1-2 minutes.',
    imageUrl: 'assets/images/marching.png',
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
    imageUrl: 'assets/images/seated_punching.png',
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
    imageUrl: 'assets/images/stepping_side_to_side.png',
  ),
  ExerciseModel(
    id: 'C4',
    title: 'Low-Impact Jumping Jacks (Step Jacks)',
    description: 'Modified full-body cardio with no jumping.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 7),
    difficultyLevel: 3,
    instructions:
        'Tap on leg sideways away from your body. At the same time as doing this, sweep both your arms in a circular motion to above your head. Bring your arms down at the same time as your leg comes in and repeat with the other leg.',
    imageUrl: 'assets/images/jumping_jack.png',
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
    imageUrl: 'assets/images/stair_climbing.png',
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
    imageUrl: 'assets/images/heel_dig.png',
  ),
];
