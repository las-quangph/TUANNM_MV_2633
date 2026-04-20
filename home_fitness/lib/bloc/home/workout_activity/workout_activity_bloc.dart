import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/storage/workout_activity_storage.dart';
import 'workout_activity_event.dart';
import 'workout_activity_state.dart';

class WorkoutActivityBloc
    extends Bloc<WorkoutActivityEvent, WorkoutActivityState> {
  WorkoutActivityBloc() : super(const WorkoutActivityState()) {
    on<LoadWorkoutActivities>(_onLoadWorkoutActivities);
    on<AppendWorkoutActivities>(_onAppendWorkoutActivities);
  }

  Future<void> _onLoadWorkoutActivities(
    LoadWorkoutActivities event,
    Emitter<WorkoutActivityState> emit,
  ) async {
    emit(
      state.copyWith(
        status: WorkoutActivityStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final activities = await WorkoutActivityStorage.loadActivities();
      emit(
        state.copyWith(
          status: WorkoutActivityStatus.ready,
          activities: activities,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: WorkoutActivityStatus.failure,
          errorMessage: 'Unable to load workout activities.',
        ),
      );
    }
  }

  Future<void> _onAppendWorkoutActivities(
    AppendWorkoutActivities event,
    Emitter<WorkoutActivityState> emit,
  ) async {
    if (event.records.isEmpty) {
      return;
    }

    try {
      await WorkoutActivityStorage.appendActivities(event.records);
      final updatedActivities = [...event.records.reversed, ...state.activities];
      emit(
        state.copyWith(
          status: WorkoutActivityStatus.ready,
          activities: updatedActivities,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: WorkoutActivityStatus.failure,
          errorMessage: 'Unable to save workout activities.',
        ),
      );
    }
  }
}
