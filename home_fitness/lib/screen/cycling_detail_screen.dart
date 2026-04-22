import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../model/workout_models.dart';
import '../route/app_routes.dart';
import '../ui_view/program_detail_view.dart';

class CyclingDetailScreen extends StatelessWidget {
  const CyclingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exerciseSequence = CyclingPlan.program.rounds
        .expand((round) => round.exercises)
        .toList(growable: false);
    return ProgramDetailView(
      program: CyclingPlan.program,
      onExerciseTap: (exercise) {
        context.push(
          AppRoutes.workoutExercise,
          extra: ExerciseDetailArgs(
            exercise: exercise,
            exerciseSequence: exerciseSequence,
            finishRoute: AppRoutes.home,
          ),
        );
      },
    );
  }
}
