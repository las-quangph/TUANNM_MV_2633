import '../../../model/workout_models.dart';

enum WorkoutActivityStatus {
  initial,
  loading,
  ready,
  failure,
}

class WorkoutActivityState {
  const WorkoutActivityState({
    this.status = WorkoutActivityStatus.initial,
    this.activities = const [],
    this.errorMessage,
  });

  final WorkoutActivityStatus status;
  final List<CompletedExerciseRecord> activities;
  final String? errorMessage;

  WorkoutActivityState copyWith({
    WorkoutActivityStatus? status,
    List<CompletedExerciseRecord>? activities,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return WorkoutActivityState(
      status: status ?? this.status,
      activities: activities ?? this.activities,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
