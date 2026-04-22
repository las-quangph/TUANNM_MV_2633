import '../../model/exercisedb_exercise.dart';
import '../../model/workout_models.dart';

enum ExerciseDetailRemoteStatus {
  initial,
  loading,
  ready,
  failure,
}

abstract class ExerciseDetailCommand {
  const ExerciseDetailCommand();
}

class ShowRestFinishedMessage extends ExerciseDetailCommand {
  const ShowRestFinishedMessage();
}

class NavigateToNextExercise extends ExerciseDetailCommand {
  const NavigateToNextExercise(this.args);

  final ExerciseDetailArgs args;
}

class FinishExerciseFlow extends ExerciseDetailCommand {
  const FinishExerciseFlow({
    required this.records,
    required this.finishRoute,
  });

  final List<CompletedExerciseRecord> records;
  final String finishRoute;
}

class ExerciseDetailState {
  const ExerciseDetailState({
    required this.exercise,
    required this.exerciseSequence,
    required this.finishRoute,
    required this.elapsedSeconds,
    required this.completedExercises,
    this.bodyWeightKg = 75,
    this.remoteStatus = ExerciseDetailRemoteStatus.initial,
    this.remoteExercise,
    this.restSecondsRemaining = 0,
    this.command,
  });

  final WorkoutExercise exercise;
  final List<WorkoutExercise> exerciseSequence;
  final String finishRoute;
  final int elapsedSeconds;
  final List<CompletedExerciseRecord> completedExercises;
  final int bodyWeightKg;
  final ExerciseDetailRemoteStatus remoteStatus;
  final ExerciseDbExercise? remoteExercise;
  final int restSecondsRemaining;
  final ExerciseDetailCommand? command;

  int get currentIndex => exerciseSequence.indexOf(exercise);

  bool get hasNext =>
      currentIndex >= 0 && currentIndex < exerciseSequence.length - 1;

  bool get isLastExercise =>
      currentIndex >= 0 && currentIndex == exerciseSequence.length - 1;

  bool get isResting => restSecondsRemaining > 0;

  WorkoutExercise? get nextExercise =>
      hasNext ? exerciseSequence[currentIndex + 1] : null;

  String get displayName {
    final remoteName = remoteExercise?.name.trim() ?? '';
    return remoteName.isNotEmpty ? remoteName : exercise.name;
  }

  String get level =>
      remoteExercise?.level ?? remoteExercise?.exerciseType ?? exercise.level;

  List<String> get instructions {
    final remoteInstructions = remoteExercise?.instructions ?? const <String>[];
    if (remoteInstructions.isNotEmpty) {
      return remoteInstructions;
    }
    return [exercise.description];
  }

  ExerciseDetailState copyWith({
    WorkoutExercise? exercise,
    List<WorkoutExercise>? exerciseSequence,
    String? finishRoute,
    int? elapsedSeconds,
    List<CompletedExerciseRecord>? completedExercises,
    int? bodyWeightKg,
    ExerciseDetailRemoteStatus? remoteStatus,
    ExerciseDbExercise? remoteExercise,
    bool clearRemoteExercise = false,
    int? restSecondsRemaining,
    ExerciseDetailCommand? command,
    bool clearCommand = false,
  }) {
    return ExerciseDetailState(
      exercise: exercise ?? this.exercise,
      exerciseSequence: exerciseSequence ?? this.exerciseSequence,
      finishRoute: finishRoute ?? this.finishRoute,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      completedExercises: completedExercises ?? this.completedExercises,
      bodyWeightKg: bodyWeightKg ?? this.bodyWeightKg,
      remoteStatus: remoteStatus ?? this.remoteStatus,
      remoteExercise:
          clearRemoteExercise ? null : remoteExercise ?? this.remoteExercise,
      restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
      command: clearCommand ? null : command ?? this.command,
    );
  }
}
