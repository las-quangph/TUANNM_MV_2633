class WorkoutExercise {
  const WorkoutExercise({
    required this.name,
    required this.duration,
    required this.repetition,
    required this.minutes,
    required this.reps,
    required this.level,
    required this.description,
    this.metValue = 6.0,
  });

  final String name;
  final String duration;
  final String repetition;
  final String minutes;
  final String reps;
  final String level;
  final String description;
  final double metValue;

  int estimateKcalBurn({
    required int durationSeconds,
    required int bodyWeightKg,
  }) {
    final minutes = durationSeconds / 60;
    final caloriesPerMinute = (metValue * 3.5 * bodyWeightKg) / 200;
    final estimated = (caloriesPerMinute * minutes).round();
    return estimated < 1 ? 1 : estimated;
  }
}

class CompletedExerciseRecord {
  const CompletedExerciseRecord({
    required this.exerciseName,
    required this.durationSeconds,
    required this.completedAt,
    required this.kcalBurned,
  });

  final String exerciseName;
  final int durationSeconds;
  final DateTime completedAt;
  final int kcalBurned;

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'durationSeconds': durationSeconds,
      'completedAt': completedAt.toIso8601String(),
      'kcalBurned': kcalBurned,
    };
  }

  factory CompletedExerciseRecord.fromJson(Map<String, dynamic> json) {
    return CompletedExerciseRecord(
      exerciseName: json['exerciseName'] as String? ?? '',
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      completedAt:
          DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
      kcalBurned: json['kcalBurned'] as int? ?? 0,
    );
  }
}

class ExerciseDetailArgs {
  const ExerciseDetailArgs({
    required this.exercise,
    this.exerciseSequence = const [],
    this.finishRoute = '/home',
    this.elapsedSeconds = 0,
    this.completedExercises = const [],
  });

  final WorkoutExercise exercise;
  final List<WorkoutExercise> exerciseSequence;
  final String finishRoute;
  final int elapsedSeconds;
  final List<CompletedExerciseRecord> completedExercises;
}

class WorkoutRound {
  const WorkoutRound({
    required this.title,
    required this.exercises,
  });

  final String title;
  final List<WorkoutExercise> exercises;
}

class WorkoutProgramData {
  const WorkoutProgramData({
    required this.heroImageAsset,
    required this.minutes,
    required this.kcal,
    required this.level,
    required this.rounds,
  });

  final String heroImageAsset;
  final String minutes;
  final String kcal;
  final String level;
  final List<WorkoutRound> rounds;
}

class WorkoutPlan {
  static const rounds = [
    WorkoutRound(
      title: 'Round 1',
      exercises: [
        WorkoutExercise(
          name: 'Pull Up (neutral grip)',
          duration: '00:30',
          repetition: 'Repetition 3x',
          minutes: '10 Minutes',
          reps: '3 Rep',
          level: 'Beginner',
          metValue: 8.0,
          description:
              'Suspend your body, lift your knees with control, and keep your core tight through every repetition.',
        ),
        WorkoutExercise(
          name: 'Dumbbell Standing Reverse Curl',
          duration: '00:15',
          repetition: 'Repetition 2x',
          minutes: '08 Minutes',
          reps: '2 Rep',
          level: 'Beginner',
          metValue: 6.5,
          description:
              'Use assistance to hold the top position, focusing on shoulder stability and upper-back tension.',
        ),
        WorkoutExercise(
          name: 'Dumbbell Decline Hammer Press',
          duration: '00:10',
          repetition: 'Repetition 2x',
          minutes: '06 Minutes',
          reps: '2 Rep',
          level: 'Beginner',
          metValue: 7.0,
          description:
              'Start from the top and lower yourself slowly to build pull-up strength with proper form.',
        ),
      ],
    ),
    WorkoutRound(
      title: 'Round 2',
      exercises: [
        WorkoutExercise(
          name: 'Scapular Pull-Up',
          duration: '00:10',
          repetition: 'Repetition 2x',
          minutes: '07 Minutes',
          reps: '2 Rep',
          level: 'Beginner',
          metValue: 5.5,
          description:
              'Activate the upper back by pulling the shoulder blades down and together without bending the elbows.',
        ),
        WorkoutExercise(
          name: 'Mith Upright Row',
          duration: '00:10',
          repetition: 'Repetition 4x',
          minutes: '09 Minutes',
          reps: '4 Rep',
          level: 'Beginner',
          metValue: 6.0,
          description:
              'Raise both knees toward your chest while hanging to challenge your grip and core control.',
        ),
      ],
    ),
  ];

  static const program = WorkoutProgramData(
    heroImageAsset: 'assets/images/img_workout.png',
    minutes: '10 Minutes',
    kcal: '120 Kcal',
    level: 'Beginner',
    rounds: rounds,
  );
}

class CyclingPlan {
  static const rounds = [
    WorkoutRound(
      title: 'Round 1',
      exercises: [
        WorkoutExercise(
          name: 'Dumbbell Burpee',
          duration: '03:00',
          repetition: '3 Mins',
          minutes: '18 Minutes',
          reps: 'Easy Pace',
          level: 'Beginner',
          metValue: 8.0,
          description:
              'Start with a smooth cadence and light resistance to warm your legs and prepare your breathing.',
        ),
        WorkoutExercise(
          name: 'Semi Squat Jump (male)',
          duration: '00:45',
          repetition: '4 Sets',
          minutes: '18 Minutes',
          reps: 'Fast Pace',
          level: 'Beginner',
          metValue: 9.0,
          description:
              'Stay seated, increase your cadence, and drive through the pedals with controlled speed.',
        ),
        WorkoutExercise(
          name: 'Stationary Bike Walk',
          duration: '01:00',
          repetition: '3 Sets',
          minutes: '18 Minutes',
          reps: 'Light Pace',
          level: 'Beginner',
          metValue: 4.5,
          description:
              'Ease off the resistance and let your breathing recover while keeping your legs moving.',
        ),
      ],
    ),
    WorkoutRound(
      title: 'Round 2',
      exercises: [
        WorkoutExercise(
          name: 'Jump Rope',
          duration: '01:30',
          repetition: '3 Sets',
          minutes: '18 Minutes',
          reps: 'High Resistance',
          level: 'Beginner',
          metValue: 10.0,
          description:
              'Add resistance and push steadily as if climbing, keeping your core stable and chest open.',
        ),
        WorkoutExercise(
          name: 'High Knee Against Wall',
          duration: '00:45',
          repetition: '2 Sets',
          minutes: '18 Minutes',
          reps: 'Power Pace',
          level: 'Beginner',
          metValue: 9.5,
          description:
              'Rise out of the saddle and finish strong with short bursts while staying balanced over the bike.',
        ),
      ],
    ),
  ];

  static const program = WorkoutProgramData(
    heroImageAsset: 'assets/images/img_cycling.png',
    minutes: '18 Minutes',
    kcal: '210 Kcal',
    level: 'Beginner',
    rounds: rounds,
  );
}
