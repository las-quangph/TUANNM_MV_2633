import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/exercise_detail/exercise_detail_bloc.dart';
import '../bloc/exercise_detail/exercise_detail_event.dart';
import '../bloc/exercise_detail/exercise_detail_state.dart';
import '../bloc/home/workout_activity/workout_activity_bloc.dart';
import '../bloc/home/workout_activity/workout_activity_event.dart';
import '../common/ext/device_ext.dart';
import '../model/workout_models.dart';
import '../route/app_routes.dart';
import '../values/app_assets.dart';
import '../values/app_colors.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.exerciseSequence = const [],
    this.finishRoute = AppRoutes.home,
    this.initialElapsedSeconds = 0,
    this.initialCompletedExercises = const [],
  });

  final WorkoutExercise exercise;
  final List<WorkoutExercise> exerciseSequence;
  final String finishRoute;
  final int initialElapsedSeconds;
  final List<CompletedExerciseRecord> initialCompletedExercises;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExerciseDetailBloc(
        exercise: exercise,
        exerciseSequence: exerciseSequence,
        finishRoute: finishRoute,
        initialElapsedSeconds: initialElapsedSeconds,
        initialCompletedExercises: initialCompletedExercises,
      )..add(const InitializeExerciseDetail()),
      child: BlocConsumer<ExerciseDetailBloc, ExerciseDetailState>(
        listener: (context, state) {
          final command = state.command;
          if (command is ShowRestFinishedMessage) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rest finished. Ready for the next set.'),
              ),
            );
            context.read<ExerciseDetailBloc>().add(
              const ClearExerciseDetailCommand(),
            );
            return;
          }
          if (command is NavigateToNextExercise) {
            context.pushReplacement(
              AppRoutes.workoutExercise,
              extra: command.args,
            );
            return;
          }
          if (command is FinishExerciseFlow) {
            context.read<WorkoutActivityBloc>().add(
              AppendWorkoutActivities(command.records),
            );
            context.go(command.finishRoute);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.bgColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 18, 8, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Image.asset(
                              AppIcons.icBack,
                              width: 55,
                              height: 30,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDuration(state.elapsedSeconds),
                            style: TextStyle(
                              color: Color(0xFFD66853),
                              fontSize: context.isPhone ? 34 : 44,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 60),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      color: const Color(0xFFE8FF54),
                      padding: const EdgeInsets.fromLTRB(26, 18, 26, 22),
                      child: Container(
                        height: context.isPhone ? 450 : 900,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _ExerciseMedia(
                          isLoading:
                              state.remoteStatus ==
                              ExerciseDetailRemoteStatus.loading,
                          gifUrl: state.remoteExercise?.gifUrl,
                          imageUrl: state.remoteExercise?.imageUrl,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8FF54),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Text(
                              state.displayName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: context.isPhone ? 22 : 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'How to do it',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: context.isPhone ? 16 : 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(
                              state.instructions.length,
                              (index) => Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index == state.instructions.length - 1
                                      ? 0
                                      : 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: context.isPhone ? 22 : 32,
                                      height: context.isPhone ? 22 : 32,
                                      margin: const EdgeInsets.only(top: 1),
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: Color(0xFFE8FF54),
                                          fontSize: context.isPhone ? 11 : 21,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        state.instructions[index],
                                        style: TextStyle(
                                          color: Color(0xFF4E4E4E),
                                          fontSize: context.isPhone ? 13 : 23,
                                          fontWeight: FontWeight.w500,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 18,
                              runSpacing: 8,
                              children: [
                                _MetaChip(
                                  icon: Icons.watch_later_rounded,
                                  label: state.exercise.minutes,
                                ),
                                _MetaChip(
                                  icon: Icons.local_fire_department_rounded,
                                  label: state.exercise.reps,
                                ),
                                _MetaChip(
                                  icon: Icons.fitness_center_rounded,
                                  label: state.level,
                                ),
                              ],
                            ),
                            if (state.hasNext || state.isLastExercise) ...[
                              if (state.isResting) ...[
                                const SizedBox(height: 18),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.pause_circle_filled_rounded,
                                        color: Color(0xFFE8FF54),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Rest time ${_formatDuration(state.restSecondsRemaining)}',
                                          style: TextStyle(
                                            color: Color(0xFFE8FF54),
                                            fontSize: context.isPhone ? 14 : 24,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.read<ExerciseDetailBloc>().add(
                                            const SkipRestRequested(),
                                          );
                                        },
                                        child: Text(
                                          'Skip Rest',
                                          style: TextStyle(
                                            color: Color(0xFFE8FF54),
                                            fontWeight: FontWeight.w700,
                                            fontSize: context.isPhone ? 14 : 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: context.isPhone ? 44 : 60,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.read<ExerciseDetailBloc>().add(
                                            state.isResting
                                                ? const SkipRestRequested()
                                                : const StartRestRequested(),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFD66853,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          state.isResting
                                              ? 'Skip Rest'
                                              : 'Rest',
                                          style: TextStyle(
                                            fontSize: context.isPhone ? 14 : 24,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: context.isPhone ? 44 : 60,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.read<ExerciseDetailBloc>().add(
                                            const PrimaryActionPressed(),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: const Color(
                                            0xFFE8FF54,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          state.hasNext ? 'Next' : 'Finish',
                                          style: TextStyle(
                                            fontSize: context.isPhone ? 14 : 24,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minuteText = minutes.toString().padLeft(2, '0');
    final secondText = seconds.toString().padLeft(2, '0');
    return '$minuteText:$secondText';
  }
}

class _ExerciseMedia extends StatelessWidget {
  const _ExerciseMedia({
    required this.isLoading,
    required this.gifUrl,
    required this.imageUrl,
  });

  final bool isLoading;
  final String? gifUrl;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE8FF54),
          ),
        ),
      );
    }

    final resolvedUrl = (gifUrl != null && gifUrl!.isNotEmpty)
        ? gifUrl!
        : imageUrl;

    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white70,
                  size: 56,
                ),
                SizedBox(height: 12),
                Text(
                  'No exercise media available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: context.isPhone ? 16 : 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Image.network(
      resolvedUrl,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white70,
                    size: 56,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Unable to load exercise media',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: context.isPhone ? 16 : 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF3B3B3B)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF3B3B3B),
            fontSize: context.isPhone ? 13 : 23,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
