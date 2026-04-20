class WorkoutExercise {
  const WorkoutExercise({
    required this.name,
    required this.duration,
    required this.repetition,
    required this.minutes,
    required this.reps,
    required this.level,
    required this.description,
  });

  final String name;
  final String duration;
  final String repetition;
  final String minutes;
  final String reps;
  final String level;
  final String description;

  int estimateKcalBurn(int durationSeconds) {
    final minutes = durationSeconds / 60;
    final estimated = (minutes * 8).round();
    return estimated < 10 ? 10 : estimated;
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
    this.elapsedSeconds = 0,
    this.completedExercises = const [],
  });

  final WorkoutExercise exercise;
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

class WorkoutPlan {
  static const rounds = [
    WorkoutRound(
      title: 'Round 1',
      exercises: [
        WorkoutExercise(
          name: 'Pull Out',
          duration: '00:30',
          repetition: 'Repetition 3x',
          minutes: '10 Minutes',
          reps: '3 Rep',
          level: 'Beginner',
          description:
              'Suspend your body, lift your knees with control, and keep your core tight through every repetition.',
        ),
        WorkoutExercise(
          name: 'Assisted Pull-Up Hold',
          duration: '00:15',
          repetition: 'Repetition 2x',
          minutes: '08 Minutes',
          reps: '2 Rep',
          level: 'Beginner',
          description:
              'Use assistance to hold the top position, focusing on shoulder stability and upper-back tension.',
        ),
        WorkoutExercise(
          name: 'Negative Pull-Up',
          duration: '00:10',
          repetition: 'Repetition 2x',
          minutes: '06 Minutes',
          reps: '2 Rep',
          level: 'Beginner',
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
          description:
              'Activate the upper back by pulling the shoulder blades down and together without bending the elbows.',
        ),
        WorkoutExercise(
          name: 'Hanging Knee Raise',
          duration: '00:10',
          repetition: 'Repetition 4x',
          minutes: '09 Minutes',
          reps: '4 Rep',
          level: 'Beginner',
          description:
              'Raise both knees toward your chest while hanging to challenge your grip and core control.',
        ),
      ],
    ),
  ];
}
