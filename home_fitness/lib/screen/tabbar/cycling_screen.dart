import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../route/app_routes.dart';
import '../../ui_view/challenge_hero_screen_view.dart';
import '../../values/app_assets.dart';

class CyclingScreen extends StatelessWidget {
  const CyclingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChallengeHeroScreenView(
      backgroundAsset: AppAssets.imgCycling,
      title: 'Cardio',
      description:
          'Set your pace, stay consistent, and build endurance with every session..',
      buttonLabel: 'Start',
      onPressed: () => context.push(AppRoutes.cyclingDetail),
    );
  }
}
