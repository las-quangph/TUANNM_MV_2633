import '../../../model/workout_models.dart';

abstract class WorkoutActivityEvent {
  const WorkoutActivityEvent();
}

class LoadWorkoutActivities extends WorkoutActivityEvent {
  const LoadWorkoutActivities();
}

class AppendWorkoutActivities extends WorkoutActivityEvent {
  const AppendWorkoutActivities(this.records);

  final List<CompletedExerciseRecord> records;
}
