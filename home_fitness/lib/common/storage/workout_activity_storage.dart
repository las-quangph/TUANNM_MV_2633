import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/workout_models.dart';

class WorkoutActivityStorage {
  static const _activitiesKey = 'workout_activity_records';
  static final ValueNotifier<int> activityVersion = ValueNotifier<int>(0);

  static Future<void> appendActivities(
    List<CompletedExerciseRecord> records,
  ) async {
    if (records.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final existing = await loadActivities();
    final updated = [...records.reversed, ...existing];
    final encoded = updated.map((record) => jsonEncode(record.toJson())).toList();
    await prefs.setStringList(_activitiesKey, encoded);
    activityVersion.value++;
  }

  static Future<List<CompletedExerciseRecord>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_activitiesKey) ?? const [];
    return rawItems
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .map(CompletedExerciseRecord.fromJson)
        .toList(growable: false);
  }
}
