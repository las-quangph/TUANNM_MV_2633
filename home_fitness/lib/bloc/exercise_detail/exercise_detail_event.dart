abstract class ExerciseDetailEvent {
  const ExerciseDetailEvent();
}

class InitializeExerciseDetail extends ExerciseDetailEvent {
  const InitializeExerciseDetail();
}

class StartRestRequested extends ExerciseDetailEvent {
  const StartRestRequested();
}

class SkipRestRequested extends ExerciseDetailEvent {
  const SkipRestRequested();
}

class PrimaryActionPressed extends ExerciseDetailEvent {
  const PrimaryActionPressed();
}

class ClearExerciseDetailCommand extends ExerciseDetailEvent {
  const ClearExerciseDetailCommand();
}

class WorkoutTimerTicked extends ExerciseDetailEvent {
  const WorkoutTimerTicked();
}

class RestTimerTicked extends ExerciseDetailEvent {
  const RestTimerTicked();
}
