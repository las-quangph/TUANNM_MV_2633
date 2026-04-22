import 'package:flutter/material.dart';

import '../common/ext/device_ext.dart';

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
                style: TextStyle(
                  color: Colors.black,
                  fontSize: context.isPhone ? 20 : 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4E4E4E),
                  fontSize: context.isPhone ? 14 : 24,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: context.isPhone ? 230 : 300,
          height: context.isPhone ? 42 : 60,
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
              style: TextStyle(
                fontSize: context.isPhone ? 16 : 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
