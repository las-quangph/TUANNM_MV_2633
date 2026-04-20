import 'package:flutter/material.dart';
import '../../ui_view/challenge_banner_view.dart';
import '../../values/app_assets.dart';

class CyclingScreen extends StatelessWidget {
  const CyclingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.imgCycling,
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
                  title: 'Daily Ride',
                  description:
                      'Set a cycling target, keep your pace steady, and build '
                      'consistent endurance with each session.',
                  buttonLabel: 'Ride Now',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
