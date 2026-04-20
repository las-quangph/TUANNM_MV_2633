import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileData {
  const UserProfileData({
    required this.fullName,
    required this.nickName,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.goal,
    this.avatarPath,
  });

  final String fullName;
  final String nickName;
  final String gender;
  final int age;
  final int weight;
  final int height;
  final String goal;
  final String? avatarPath;

  String get displayName {
    final nick = nickName.trim();
    if (nick.isNotEmpty) {
      return nick;
    }
    return fullName.trim();
  }

  UserProfileData copyWith({
    String? fullName,
    String? nickName,
    String? gender,
    int? age,
    int? weight,
    int? height,
    String? goal,
    String? avatarPath,
    bool clearAvatarPath = false,
  }) {
    return UserProfileData(
      fullName: fullName ?? this.fullName,
      nickName: nickName ?? this.nickName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      avatarPath: clearAvatarPath ? null : avatarPath ?? this.avatarPath,
    );
  }

  String get initials {
    final trimmed = displayName;
    if (trimmed.isEmpty) {
      return 'U';
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.first.substring(0, 1).toUpperCase();
    final second = parts.length > 1 ? parts.last.substring(0, 1).toUpperCase() : '';
    return '$first$second';
  }
}

class UserProfileStorage {
  static const _fullNameKey = 'user_profile_full_name';
  static const _nickNameKey = 'user_profile_nick_name';
  static const _genderKey = 'user_profile_gender';
  static const _ageKey = 'user_profile_age';
  static const _weightKey = 'user_profile_weight';
  static const _heightKey = 'user_profile_height';
  static const _goalKey = 'user_profile_goal';
  static const _avatarPathKey = 'user_profile_avatar_path';
  static final ValueNotifier<int> profileVersion = ValueNotifier<int>(0);

  static Future<void> save(UserProfileData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullNameKey, data.fullName);
    await prefs.setString(_nickNameKey, data.nickName);
    await prefs.setString(_genderKey, data.gender);
    await prefs.setInt(_ageKey, data.age);
    await prefs.setInt(_weightKey, data.weight);
    await prefs.setInt(_heightKey, data.height);
    await prefs.setString(_goalKey, data.goal);

    if (data.avatarPath == null || data.avatarPath!.isEmpty) {
      await prefs.remove(_avatarPathKey);
    } else {
      await prefs.setString(_avatarPathKey, data.avatarPath!);
    }

    profileVersion.value++;
  }

  static Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString(_fullNameKey)?.trim() ?? '';
    final nickName = prefs.getString(_nickNameKey)?.trim() ?? '';
    return fullName.isNotEmpty || nickName.isNotEmpty;
  }

  static Future<UserProfileData> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfileData(
      fullName: prefs.getString(_fullNameKey) ?? 'Madison Smith',
      nickName: prefs.getString(_nickNameKey) ?? 'Madison',
      gender: prefs.getString(_genderKey) ?? 'female',
      age: prefs.getInt(_ageKey) ?? 28,
      weight: prefs.getInt(_weightKey) ?? 75,
      height: prefs.getInt(_heightKey) ?? 165,
      goal: prefs.getString(_goalKey) ?? 'Lose Weight',
      avatarPath: prefs.getString(_avatarPathKey),
    );
  }
}
