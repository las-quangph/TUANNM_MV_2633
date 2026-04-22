import 'package:flutter/material.dart';
import 'package:home_fitness/common/ext/device_ext.dart';

import '../model/workout_models.dart';
import '../values/app_assets.dart';
import '../values/app_colors.dart';

class ProgramDetailView extends StatelessWidget {
  const ProgramDetailView({
    super.key,
    required this.program,
    required this.onExerciseTap,
  });

  final WorkoutProgramData program;
  final ValueChanged<WorkoutExercise> onExerciseTap;

  @override
  Widget build(BuildContext context) {
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
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Image.asset(AppIcons.icBack, width: 55, height: 30),
                ),
              ),
              const SizedBox(height: 26),
              _ProgramHeroCard(program: program),
              const SizedBox(height: 20),
              ...program.rounds.map(
                (round) => _RoundSection(
                  round: round,
                  onExerciseTap: (exercise) => onExerciseTap(exercise),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramHeroCard extends StatelessWidget {
  const _ProgramHeroCard({
    required this.program,
  });

  final WorkoutProgramData program;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE8FF54),
      padding: const EdgeInsets.fromLTRB(40, 30, 40, 30),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(22),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: context.isPhone ? 175 : 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    program.heroImageAsset,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.25),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.10),
                          Colors.black.withValues(alpha: 0.25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  _HeroMeta(
                    icon: Icons.watch_later_rounded,
                    text: program.minutes,
                  ),
                  const SizedBox(width: 20),
                  _HeroMeta(
                    icon: Icons.local_fire_department_rounded,
                    text: program.kcal,
                  ),
                  const SizedBox(width: 20),
                  _HeroMeta(
                    icon: Icons.fitness_center_rounded,
                    text: program.level,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white70,
            fontSize: context.isPhone ? 12 : 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RoundSection extends StatelessWidget {
  const _RoundSection({required this.round, required this.onExerciseTap});

  final WorkoutRound round;
  final ValueChanged<WorkoutExercise> onExerciseTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            round.title,
            style: TextStyle(
              color: Color(0xFFE8FF54),
              fontSize: context.isPhone ? 20 : 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...round.exercises.map(
            (exercise) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ExerciseTile(
                exercise: exercise,
                onTap: () => onExerciseTap(exercise),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.onTap});

  final WorkoutExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Container(
              width: context.isPhone ? 40 : 60,
              height: context.isPhone ? 40 : 60,
              decoration: const BoxDecoration(
                color: Color(0xFFE8FF54),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                exercise.name,
                style: TextStyle(
                  color: Color(0xFF2A2A2A),
                  fontSize: context.isPhone ? 16 : 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              exercise.repetition,
              style: TextStyle(
                color: Color(0xFF9DDB48),
                fontSize: context.isPhone ? 14 : 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
