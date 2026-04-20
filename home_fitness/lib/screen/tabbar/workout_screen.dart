import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../route/app_routes.dart';
import '../../ui_view/challenge_banner_view.dart';
import '../../values/app_assets.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.imgWorkout,
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.18),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.24),
                ],
                stops: const [0, 0.35, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Center(
                child: ChallengeBannerView(
                  title: 'Weekly Challenge',
                  description:
                      'Bringing you fresh challenges every week to sharpen '
                      'your skills, maintain good habits, and stay motivated '
                      'for personal growth.',
                  buttonLabel: 'Start Now',
                  onPressed: () => context.push(AppRoutes.workoutDetail),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
