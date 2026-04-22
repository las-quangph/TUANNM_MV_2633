import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/storage/user_profile_storage.dart';
import '../../common/exercisedb_service.dart';
import '../../model/workout_models.dart';
import 'exercise_detail_event.dart';
import 'exercise_detail_state.dart';

class ExerciseDetailBloc
    extends Bloc<ExerciseDetailEvent, ExerciseDetailState> {
  ExerciseDetailBloc({
    required WorkoutExercise exercise,
    required List<WorkoutExercise> exerciseSequence,
    required String finishRoute,
    required int initialElapsedSeconds,
    required List<CompletedExerciseRecord> initialCompletedExercises,
    ExerciseDbService? exerciseDbService,
  })  : _exerciseDbService = exerciseDbService ?? ExerciseDbService(),
        super(
          ExerciseDetailState(
            exercise: exercise,
            exerciseSequence: exerciseSequence.isEmpty
                ? [exercise]
                : exerciseSequence,
            finishRoute: finishRoute,
            elapsedSeconds: initialElapsedSeconds,
            completedExercises: initialCompletedExercises,
          ),
        ) {
    on<InitializeExerciseDetail>(_onInitializeExerciseDetail);
    on<StartRestRequested>(_onStartRestRequested);
    on<SkipRestRequested>(_onSkipRestRequested);
    on<PrimaryActionPressed>(_onPrimaryActionPressed);
    on<ClearExerciseDetailCommand>(_onClearExerciseDetailCommand);
    on<WorkoutTimerTicked>(_onWorkoutTimerTicked);
    on<RestTimerTicked>(_onRestTimerTicked);
  }

  static const int _defaultRestSeconds = 30;
  final ExerciseDbService _exerciseDbService;
  Timer? _workoutTimer;
  Timer? _restTimer;

  Future<void> _onInitializeExerciseDetail(
    InitializeExerciseDetail event,
    Emitter<ExerciseDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        remoteStatus: ExerciseDetailRemoteStatus.loading,
        clearCommand: true,
      ),
    );
    _startWorkoutTimer();
    final profile = await UserProfileStorage.load();
    final remoteExercise =
        await _exerciseDbService.fetchExerciseByName(state.exercise.name);
    emit(
      state.copyWith(
        bodyWeightKg: profile.weight,
        remoteStatus: ExerciseDetailRemoteStatus.ready,
        remoteExercise: remoteExercise,
      ),
    );
  }

  void _onStartRestRequested(
    StartRestRequested event,
    Emitter<ExerciseDetailState> emit,
  ) {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    emit(
      state.copyWith(
        restSecondsRemaining: _defaultRestSeconds,
        clearCommand: true,
      ),
    );
    _restTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const RestTimerTicked()),
    );
  }

  void _onSkipRestRequested(
    SkipRestRequested event,
    Emitter<ExerciseDetailState> emit,
  ) {
    if (!state.isResting) {
      return;
    }
    _restTimer?.cancel();
    _startWorkoutTimer();
    emit(state.copyWith(restSecondsRemaining: 0, clearCommand: true));
  }

  void _onPrimaryActionPressed(
    PrimaryActionPressed event,
    Emitter<ExerciseDetailState> emit,
  ) {
    final updatedRecords = _buildCompletedExercises(state);
    final nextExercise = state.nextExercise;
    if (nextExercise != null) {
      emit(
        state.copyWith(
          command: NavigateToNextExercise(
            ExerciseDetailArgs(
              exercise: nextExercise,
              exerciseSequence: state.exerciseSequence,
              finishRoute: state.finishRoute,
              elapsedSeconds: state.elapsedSeconds,
              completedExercises: updatedRecords,
            ),
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        command: FinishExerciseFlow(
          records: updatedRecords,
          finishRoute: state.finishRoute,
        ),
      ),
    );
  }

  void _onClearExerciseDetailCommand(
    ClearExerciseDetailCommand event,
    Emitter<ExerciseDetailState> emit,
  ) {
    emit(state.copyWith(clearCommand: true));
  }

  void _onWorkoutTimerTicked(
    WorkoutTimerTicked event,
    Emitter<ExerciseDetailState> emit,
  ) {
    emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
  }

  void _onRestTimerTicked(
    RestTimerTicked event,
    Emitter<ExerciseDetailState> emit,
  ) {
    if (state.restSecondsRemaining <= 1) {
      _restTimer?.cancel();
      _startWorkoutTimer();
      emit(
        state.copyWith(
          restSecondsRemaining: 0,
          command: const ShowRestFinishedMessage(),
        ),
      );
      return;
    }
    emit(
      state.copyWith(restSecondsRemaining: state.restSecondsRemaining - 1),
    );
  }

  List<CompletedExerciseRecord> _buildCompletedExercises(
    ExerciseDetailState currentState,
  ) {
    final updatedRecords =
        List<CompletedExerciseRecord>.from(currentState.completedExercises);
    final previousTotalDuration =
        updatedRecords.fold<int>(0, (sum, item) => sum + item.durationSeconds);
    final currentDuration = currentState.elapsedSeconds - previousTotalDuration;
    if (currentDuration <= 0) {
      return updatedRecords;
    }

    updatedRecords.add(
      CompletedExerciseRecord(
        exerciseName: currentState.exercise.name,
        durationSeconds: currentDuration,
        completedAt: DateTime.now(),
        kcalBurned: currentState.exercise.estimateKcalBurn(
          durationSeconds: currentDuration,
          bodyWeightKg: currentState.bodyWeightKg,
        ),
      ),
    );
    return updatedRecords;
  }

  void _startWorkoutTimer() {
    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const WorkoutTimerTicked()),
    );
  }

  @override
  Future<void> close() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    return super.close();
  }
}
