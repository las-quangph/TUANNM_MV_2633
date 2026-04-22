import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/app_links.dart';
import '../../common/ext/device_ext.dart';
import '../../common/storage/user_profile_storage.dart';
import '../../route/app_routes.dart';
import '../../ui_view/profile_header_view.dart';
import '../../values/app_colors.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted || launched) {
      return;
    }
    _showActionError('Unable to open link.');
  }

  Future<void> _rateApp() async {
    await _launchExternalUrl(AppLinks.rateAppUrl);
  }

  Future<void> _openPrivacyPolicy() async {
    await _launchExternalUrl(AppLinks.privacyPolicyUrl);
  }

  Future<void> _shareApp() async {
    try {
      await Share.share(AppLinks.shareMessage);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showActionError('Unable to share app right now.');
    }
  }

  void _showActionError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: UserProfileStorage.profileVersion,
          builder: (context, value, child) {
            return FutureBuilder<UserProfileData>(
              future: UserProfileStorage.load(),
              builder: (context, snapshot) {
                final profile = snapshot.data ??
                    const UserProfileData(
                      fullName: 'Madison Smith',
                      nickName: 'Madison',
                      gender: 'female',
                      age: 28,
                      weight: 75,
                      height: 165,
                      goal: 'Lose Weight',
                    );

                return Column(
                  children: [
                    const SizedBox(height: 100),
                    ProfileHeaderView(profile: profile),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(28, 100, 28, 24),
                        children: [
                          _SettingMenuTile(
                            icon: Icons.person,
                            label: 'Profile',
                            onTap: () async {
                              await context.push(AppRoutes.editProfile);
                            },
                          ),
                          const SizedBox(height: 22),
                          _SettingMenuTile(
                            icon: Icons.star_rounded,
                            label: 'Rate App',
                            onTap: _rateApp,
                          ),
                          const SizedBox(height: 22),
                          _SettingMenuTile(
                            icon: Icons.lock,
                            label: 'Privacy Policy',
                            onTap: _openPrivacyPolicy,
                          ),
                          const SizedBox(height: 22),
                          _SettingMenuTile(
                            icon: Icons.send_rounded,
                            label: 'Share App',
                            onTap: _shareApp,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SettingMenuTile extends StatelessWidget {
  const _SettingMenuTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: context.isPhone ? 30 : 50,
              height: context.isPhone ? 30 : 50,
              decoration: const BoxDecoration(
                color: Color(0xFF9DDB48),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: context.isPhone ? 18 : 28, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.isPhone ? 16 : 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9DDB48),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
