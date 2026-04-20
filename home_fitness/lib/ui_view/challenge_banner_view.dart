import 'package:flutter/material.dart';

class ChallengeBannerView extends StatelessWidget {
  const ChallengeBannerView({
    super.key,
    required this.title,
    required this.description,
    required this.buttonLabel,
    this.onPressed,
    this.bannerColor = const Color(0xFFE8FF54),
  });

  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final Color bannerColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
          color: bannerColor,
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF4E4E4E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 230,
          height: 42,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.75),
                width: 1.5,
              ),
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
