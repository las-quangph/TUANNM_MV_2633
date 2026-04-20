import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/home/workout_activity/workout_activity_bloc.dart';
import '../bloc/home/workout_activity/workout_activity_event.dart';
import '../common/exercisedb_service.dart';
import '../model/exercisedb_exercise.dart';
import '../model/workout_models.dart';
import '../route/app_routes.dart';
import '../values/app_assets.dart';
import '../values/app_colors.dart';

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.initialElapsedSeconds = 0,
    this.initialCompletedExercises = const [],
  });

  final WorkoutExercise exercise;
  final int initialElapsedSeconds;
  final List<CompletedExerciseRecord> initialCompletedExercises;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  static const int _defaultRestSeconds = 30;
  late final Future<ExerciseDbExercise?> _remoteExerciseFuture;
  static final List<WorkoutExercise> _allExercises = WorkoutPlan.rounds
      .expand((round) => round.exercises)
      .toList(growable: false);
  Timer? _timer;
  Timer? _restTimer;
  int _elapsedSeconds = 0;
  int _restSecondsRemaining = 0;
  late final List<CompletedExerciseRecord> _completedExercises;

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = widget.initialElapsedSeconds;
    _completedExercises = List<CompletedExerciseRecord>.from(
      widget.initialCompletedExercises,
    );
    _remoteExerciseFuture =
        ExerciseDbService().fetchExerciseByName(widget.exercise.name);
    _startWorkoutTimer();
  }

  void _startWorkoutTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: FutureBuilder<ExerciseDbExercise?>(
          future: _remoteExerciseFuture,
          builder: (context, snapshot) {
            final remote = snapshot.data;
            final displayName =
                (remote?.name.trim().isNotEmpty ?? false)
                    ? remote!.name
                    : widget.exercise.name;
            final level =
                remote?.level ?? remote?.exerciseType ?? widget.exercise.level;
            final instructions = _buildInstructions(remote);
            final currentIndex = _allExercises.indexOf(widget.exercise);
            final hasNext =
                currentIndex >= 0 && currentIndex < _allExercises.length - 1;
            final isLastExercise =
                currentIndex == _allExercises.length - 1 && currentIndex >= 0;

            return SingleChildScrollView(
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
                          _formattedElapsedTime,
                          style: TextStyle(
                            color: Color(0xFFD66853),
                            fontSize: 34,
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
                      height: 450,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _ExerciseMedia(
                        isLoading:
                            snapshot.connectionState == ConnectionState.waiting,
                        gifUrl: remote?.gifUrl,
                        imageUrl: remote?.imageUrl,
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
                            displayName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'How to do it',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(
                            instructions.length,
                            (index) => Padding(
                              padding: EdgeInsets.only(
                                bottom: index == instructions.length - 1 ? 0 : 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    margin: const EdgeInsets.only(top: 1),
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Color(0xFFE8FF54),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      instructions[index],
                                      style: const TextStyle(
                                        color: Color(0xFF4E4E4E),
                                        fontSize: 13,
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
                                label: widget.exercise.minutes,
                              ),
                              _MetaChip(
                                icon: Icons.local_fire_department_rounded,
                                label: widget.exercise.reps,
                              ),
                              _MetaChip(
                                icon: Icons.fitness_center_rounded,
                                label: level,
                              ),
                            ],
                          ),
                          if (hasNext || isLastExercise) ...[
                            if (_restSecondsRemaining > 0) ...[
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
                                        'Rest time $_formattedRestTime',
                                        style: const TextStyle(
                                          color: Color(0xFFE8FF54),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _stopRestTimer,
                                      child: const Text(
                                        'Skip Rest',
                                        style: TextStyle(
                                          color: Color(0xFFE8FF54),
                                          fontWeight: FontWeight.w700,
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
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: _restSecondsRemaining > 0
                                          ? _stopRestTimer
                                          : _startRestTimer,
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
                                        _restSecondsRemaining > 0
                                            ? 'Skip Rest'
                                            : 'Rest',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (hasNext) {
                                          final nextExercise =
                                              _allExercises[currentIndex + 1];
                                          final updatedRecords =
                                              _buildCompletedExercises();
                                          context.pushReplacement(
                                            AppRoutes.workoutExercise,
                                            extra: ExerciseDetailArgs(
                                              exercise: nextExercise,
                                              elapsedSeconds: _elapsedSeconds,
                                              completedExercises: updatedRecords,
                                            ),
                                          );
                                          return;
                                        }

                                        final updatedRecords =
                                            _buildCompletedExercises();
                                        context.read<WorkoutActivityBloc>().add(
                                          AppendWorkoutActivities(
                                            updatedRecords,
                                          ),
                                        );
                                        if (!context.mounted) {
                                          return;
                                        }
                                        context.go(AppRoutes.workout);
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
                                        hasNext ? 'Next' : 'Finish',
                                        style: const TextStyle(
                                          fontSize: 14,
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
            );
          },
        ),
      ),
    );
  }

  List<String> _buildInstructions(ExerciseDbExercise? remote) {
    if (remote != null && remote.instructions.isNotEmpty) {
      return remote.instructions;
    }
    return [widget.exercise.description];
  }

  String get _formattedElapsedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    final minuteText = minutes.toString().padLeft(2, '0');
    final secondText = seconds.toString().padLeft(2, '0');
    return '$minuteText:$secondText';
  }

  List<CompletedExerciseRecord> _buildCompletedExercises() {
    final updatedRecords = List<CompletedExerciseRecord>.from(_completedExercises);
    final currentDuration = _currentExerciseDurationSeconds;
    if (currentDuration <= 0) {
      return updatedRecords;
    }

    updatedRecords.add(
      CompletedExerciseRecord(
        exerciseName: widget.exercise.name,
        durationSeconds: currentDuration,
        completedAt: DateTime.now(),
        kcalBurned: widget.exercise.estimateKcalBurn(currentDuration),
      ),
    );
    return updatedRecords;
  }

  int get _currentExerciseDurationSeconds {
    final duration = _elapsedSeconds - widget.initialElapsedSeconds;
    if (duration < 0) {
      return 0;
    }
    return duration;
  }

  String get _formattedRestTime {
    final minutes = _restSecondsRemaining ~/ 60;
    final seconds = _restSecondsRemaining % 60;
    final minuteText = minutes.toString().padLeft(2, '0');
    final secondText = seconds.toString().padLeft(2, '0');
    return '$minuteText:$secondText';
  }

  void _startRestTimer() {
    _timer?.cancel();
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = _defaultRestSeconds;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_restSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _restSecondsRemaining = 0;
        });
        _startWorkoutTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rest finished. Ready for the next set.'),
          ),
        );
        return;
      }
      setState(() {
        _restSecondsRemaining--;
      });
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    if (!mounted || _restSecondsRemaining == 0) {
      return;
    }
    setState(() {
      _restSecondsRemaining = 0;
    });
    _startWorkoutTimer();
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
      return const DecoratedBox(
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
                    fontSize: 16,
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
        return const DecoratedBox(
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
                      fontSize: 16,
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
          style: const TextStyle(
            color: Color(0xFF3B3B3B),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
