import 'dart:io';

import 'package:flutter/material.dart';

import '../common/ext/device_ext.dart';
import '../common/storage/user_profile_storage.dart';

class ProfileHeaderView extends StatelessWidget {
  const ProfileHeaderView({
    super.key,
    required this.profile,
    this.avatarPath,
    this.onEditAvatar,
    this.avatarSize = 140,
    this.titleFontSize = 30,
    this.headerPadding = const EdgeInsets.fromLTRB(24, 26, 24, 48),
    this.statsHorizontalPadding = 18,
    this.statsVerticalPadding = 14,
    this.statsLeft = 28,
    this.statsRight = 28,
    this.statsBottom = -24,
    this.statsColor = const Color(0xFF95D24C),
    this.showBottomSpacer = true,
    this.nameTopSpacing = 12,
  });

  final UserProfileData profile;
  final String? avatarPath;
  final VoidCallback? onEditAvatar;
  final double avatarSize;
  final double titleFontSize;
  final EdgeInsets headerPadding;
  final double statsHorizontalPadding;
  final double statsVerticalPadding;
  final double statsLeft;
  final double statsRight;
  final double statsBottom;
  final Color statsColor;
  final bool showBottomSpacer;
  final double nameTopSpacing;

  @override
  Widget build(BuildContext context) {
    final resolvedAvatarPath = avatarPath ?? profile.avatarPath;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          padding: headerPadding,
          color: const Color(0xFFE8FF54),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ProfileAvatar(
                profile: profile,
                avatarPath: resolvedAvatarPath,
                size: avatarSize,
                onTap: onEditAvatar,
              ),
              SizedBox(height: nameTopSpacing),
              Text(
                profile.displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: context.isPhone ? 18 : 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showBottomSpacer) const SizedBox(height: 12),
            ],
          ),
        ),
        Positioned(
          bottom: context.isPhone ? - 25 : -50,
          left: statsLeft,
          right: statsRight,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: statsHorizontalPadding,
              vertical: statsVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: statsColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    value: '${profile.weight} Kg',
                    label: 'Weight',
                  ),
                ),
                const _ProfileStatDivider(),
                Expanded(
                  child: _ProfileStat(
                    value: '${profile.age}',
                    label: 'Years Old',
                  ),
                ),
                const _ProfileStatDivider(),
                Expanded(
                  child: _ProfileStat(
                    value: '${_formatHeight(profile.height)} CM',
                    label: 'Height',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatHeight(int heightInCm) {
    if (heightInCm >= 100) {
      return (heightInCm / 100).toStringAsFixed(2);
    }
    return heightInCm.toString();
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.profile,
    required this.avatarPath,
    required this.size,
    this.onTap,
  });

  final UserProfileData profile;
  final String? avatarPath;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarPath != null && File(avatarPath!).existsSync();

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF202020),
        image: hasAvatar
            ? DecorationImage(
                image: FileImage(File(avatarPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: hasAvatar
          ? null
          : Text(
              profile.initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.isPhone ? 28 : 38,
                fontWeight: FontWeight.w800,
              ),
            ),
    );

    if (onTap == null) {
      return avatar;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: 6,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFE8FF54),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                size: 25,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.isPhone ? 15 : 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.isPhone ? 13 : 23,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _ProfileStatDivider extends StatelessWidget {
  const _ProfileStatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: 0.45),
    );
  }
}
