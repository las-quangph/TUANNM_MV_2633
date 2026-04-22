import 'package:flutter/material.dart';

import 'challenge_banner_view.dart';

class ChallengeHeroScreenView extends StatelessWidget {
  const ChallengeHeroScreenView({
    super.key,
    required this.backgroundAsset,
    required this.title,
    required this.description,
    required this.buttonLabel,
    this.onPressed,
  });

  final String backgroundAsset;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            backgroundAsset,
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
                  title: title,
                  description: description,
                  buttonLabel: buttonLabel,
                  onPressed: onPressed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
