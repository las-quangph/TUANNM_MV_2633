import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../bloc/home/workout_activity/workout_activity_bloc.dart';
import '../../bloc/home/workout_activity/workout_activity_state.dart';
import '../../common/ext/device_ext.dart';
import '../../common/storage/user_profile_storage.dart';
import '../../model/workout_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeViewTab _selectedTab = HomeViewTab.workoutLog;
  late DateTime _focusedDay;
  late DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
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

                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileSummaryCard(profile: profile),
                      const SizedBox(height: 18),
                      _HomeTabSwitcher(
                        selectedTab: _selectedTab,
                        onChanged: (tab) {
                          setState(() {
                            _selectedTab = tab;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _selectedTab == HomeViewTab.workoutLog
                              ? _WorkoutLogView(
                                  key: const ValueKey('workout'),
                                  focusedDay: _focusedDay,
                                  selectedDay: _selectedDay,
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });
                                  },
                                )
                              : _ChartView(
                                  key: const ValueKey('chart'),
                                  selectedDay: _selectedDay,
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

enum HomeViewTab {
  workoutLog,
  chart,
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.profile,
  });

  final UserProfileData profile;

  @override
  Widget build(BuildContext context) {
    final avatarPath = profile.avatarPath;
    final avatarExists = avatarPath != null && File(avatarPath).existsSync();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7FF57),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.nickName.isEmpty ? profile.fullName : profile.nickName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.isPhone ? 19 : 29,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _MetricPill(value: '${profile.weight} Kg', label: 'Weight'),
                    const SizedBox(width: 30),
                    _MetricPill(value: '${profile.height} CM', label: 'Height'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: context.isPhone ? 125 : 200,
            height: context.isPhone ? 125 : 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: avatarExists
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFFF8E7DD), Color(0xFFB5846F)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              border: Border.all(color: Colors.black12),
              image: avatarExists
                  ? DecorationImage(
                      image: FileImage(File(avatarPath)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: avatarExists
                ? null
                : Text(
                    profile.initials,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: context.isPhone ? 6 : 10,
          height: context.isPhone ? 32 : 60,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: context.isPhone ? 14 : 24,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: context.isPhone ? 13 : 23,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HomeTabSwitcher extends StatelessWidget {
  const _HomeTabSwitcher({
    required this.selectedTab,
    required this.onChanged,
  });

  final HomeViewTab selectedTab;
  final ValueChanged<HomeViewTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabChip(
            label: 'Workout Log',
            selected: selectedTab == HomeViewTab.workoutLog,
            onTap: () => onChanged(HomeViewTab.workoutLog),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _TabChip(
            label: 'Charts',
            selected: selectedTab == HomeViewTab.chart,
            onTap: () => onChanged(HomeViewTab.chart),
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: context.isPhone ? 42 : 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE7FF57) : Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : const Color(0xFF7B8EEB),
            fontWeight: FontWeight.w600,
            fontSize: context.isPhone ? 18 : 28,
          ),
        ),
      ),
    );
  }
}

class _WorkoutLogView extends StatelessWidget {
  const _WorkoutLogView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutActivityBloc, WorkoutActivityState>(
      builder: (context, state) {
        final filteredActivities = state.activities.where((activity) {
          if (selectedDay == null) {
            return true;
          }
          return isSameDay(activity.completedAt, selectedDay);
        }).toList(growable: false);

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _CalendarCard(
              focusedDay: focusedDay,
              selectedDay: selectedDay,
              onDaySelected: onDaySelected,
            ),
            const SizedBox(height: 22),
            Text(
              'Activities',
              style: TextStyle(
                color: Color(0xFFE7FF57),
                fontSize: context.isPhone ? 20 : 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            if (state.status == WorkoutActivityStatus.loading &&
                state.activities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFE7FF57),
                  ),
                ),
              )
            else if (filteredActivities.isEmpty)
              _EmptyActivitiesCard(selectedDay: selectedDay)
            else
              ...List.generate(filteredActivities.length, (index) {
                final activity = filteredActivities[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == filteredActivities.length - 1 ? 0 : 12,
                  ),
                  child: _ActivityCard(
                    kcal: '${activity.kcalBurned} Kcal',
                    title: activity.exerciseName,
                    subtitle: _formatCompletedAt(activity.completedAt),
                    duration: _formatDuration(activity.durationSeconds),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  static String _formatCompletedAt(DateTime completedAt) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[completedAt.month - 1];
    final day = completedAt.day.toString().padLeft(2, '0');
    final rawHour =
        completedAt.hour > 12 ? completedAt.hour - 12 : completedAt.hour;
    final hour = (rawHour == 0 ? 12 : rawHour).toString();
    final minute = completedAt.minute.toString().padLeft(2, '0');
    final meridiem = completedAt.hour >= 12 ? 'PM' : 'AM';
    return '$month $day - $hour:$minute $meridiem';
  }

  static String _formatDuration(int durationSeconds) {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes == 0) {
      return '${seconds}s';
    }
    if (seconds == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }
}

class _ChartView extends StatelessWidget {
  const _ChartView({
    super.key,
    required this.selectedDay,
  });

  final DateTime? selectedDay;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutActivityBloc, WorkoutActivityState>(
      builder: (context, state) {
        final anchorDay = selectedDay ?? DateTime.now();
        final chartPoints = _buildWeeklyChartPoints(
          activities: state.activities,
          anchorDay: anchorDay,
        );
        final daySummary = _buildDaySummary(
          activities: state.activities,
          selectedDay: anchorDay,
        );

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            Text(
              'My Progress',
              style: TextStyle(
                color: Color(0xFFE7FF57),
                fontSize: context.isPhone ? 18 : 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatChartHeader(anchorDay),
              style: TextStyle(
                color: Color(0xFFE7FF57),
                fontSize: context.isPhone ? 30 : 40,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _ChartCard(points: chartPoints),
            const SizedBox(height: 16),
            _SummaryStrip(summary: daySummary),
          ],
        );
      },
    );
  }

  static List<_DailyKcalPoint> _buildWeeklyChartPoints({
    required List<CompletedExerciseRecord> activities,
    required DateTime anchorDay,
  }) {
    final normalizedAnchor = DateTime(anchorDay.year, anchorDay.month, anchorDay.day);
    return List.generate(7, (index) {
      final day = normalizedAnchor.subtract(Duration(days: 6 - index));
      final kcal = activities
          .where((activity) => isSameDay(activity.completedAt, day))
          .fold<int>(0, (sum, item) => sum + item.kcalBurned);
      return _DailyKcalPoint(
        date: day,
        kcal: kcal,
      );
    });
  }

  static _DaySummary _buildDaySummary({
    required List<CompletedExerciseRecord> activities,
    required DateTime selectedDay,
  }) {
    final dayActivities = activities
        .where((activity) => isSameDay(activity.completedAt, selectedDay))
        .toList(growable: false);
    final totalKcal =
        dayActivities.fold<int>(0, (sum, item) => sum + item.kcalBurned);
    final totalDuration = dayActivities.fold<int>(
      0,
      (sum, item) => sum + item.durationSeconds,
    );
    return _DaySummary(
      weekday: _weekdayLabel(selectedDay),
      totalKcal: totalKcal,
      totalDurationSeconds: totalDuration,
    );
  }

  static String _formatChartHeader(DateTime date) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[date.month - 1]} ${date.day}th';
  }

  static String _weekdayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TableCalendar<void>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: focusedDay,
        daysOfWeekHeight: context.isPhone ? 16 : 36,
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          headerPadding: EdgeInsets.symmetric(
            vertical: context.isPhone ? 6 : 12,
          ),
          titleTextFormatter: (date, locale) {
            const monthNames = [
              'January',
              'February',
              'March',
              'April',
              'May',
              'June',
              'July',
              'August',
              'September',
              'October',
              'November',
              'December',
            ];
            return '${monthNames[date.month - 1]} ${date.year}';
          },
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF2C2C2C),
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF2C2C2C),
          ),
          titleTextStyle: TextStyle(
            color: const Color(0xFF2C2C2C),
            fontSize: context.isPhone ? 16 : 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Color(0xFF5C7CF6),
            fontWeight: FontWeight.w700,
            fontSize: context.isPhone ? 11 : 21,
          ),
          weekendStyle: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w700,
            fontSize: context.isPhone ? 11 : 21,
          ),
        ),
        rowHeight: context.isPhone ? 34 : 50,
        availableGestures: AvailableGestures.horizontalSwipe,
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          defaultTextStyle: TextStyle(
            color: Color(0xFF5C7CF6),
            fontWeight: FontWeight.w600,
            fontSize: context.isPhone ? 12 : 22,
          ),
          weekendTextStyle: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w600,
            fontSize: context.isPhone ? 12 : 22,
          ),
          outsideTextStyle: TextStyle(
            color: Color(0xFFB8B8B8),
            fontWeight: FontWeight.w500,
            fontSize: context.isPhone ? 12 : 22,
          ),
          selectedTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: context.isPhone ? 12 : 22,
          ),
          selectedDecoration: BoxDecoration(
            color: Color(0xFFE7FF57),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: Color(0xFF5C7CF6),
            fontWeight: FontWeight.w700,
            fontSize: context.isPhone ? 12 : 22,
          ),
          cellMargin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          cellPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.kcal,
    required this.title,
    required this.subtitle,
    required this.duration,
  });

  final String kcal;
  final String title;
  final String subtitle;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: context.isPhone ? 44 : 60,
            height: context.isPhone ? 44 : 60,
            decoration: const BoxDecoration(
              color: Color(0xFF6E89F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_run_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kcal,
                  style: TextStyle(
                    color: Color(0xFFA1A1A1),
                    fontSize: context.isPhone ? 11 : 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.isPhone ? 22 : 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Color(0xFF8C79F7),
                    fontSize: context.isPhone ? 14 : 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timelapse_rounded, color: Color(0xFF6E89F5), size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Duration',
                    style: TextStyle(
                      color: Color(0xFF6E89F5),
                      fontSize: context.isPhone ? 12 : 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                duration,
                style: TextStyle(
                  color: Color(0xFF6E89F5),
                  fontSize: context.isPhone ? 22 : 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyActivitiesCard extends StatelessWidget {
  const _EmptyActivitiesCard({
    required this.selectedDay,
  });

  final DateTime? selectedDay;

  @override
  Widget build(BuildContext context) {
    final dateText =
        selectedDay == null
            ? 'this day'
            : '${selectedDay!.day.toString().padLeft(2, '0')}/${selectedDay!.month.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'No activities recorded for $dateText yet.',
        style: TextStyle(
          color: Color(0xFF6E89F5),
          fontSize: context.isPhone ? 15 : 25,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.points,
  });

  final List<_DailyKcalPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxKcal = points.fold<int>(0, (max, point) {
      return point.kcal > max ? point.kcal : max;
    });
    final effectiveMax = maxKcal <= 0 ? 40 : ((maxKcal + 19) ~/ 20) * 20;
    final axisValues = [
      effectiveMax,
      (effectiveMax * 0.66).round(),
      (effectiveMax * 0.33).round(),
      0,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white70),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kcal Burned',
            style: TextStyle(
              color: Color(0xFFE7FF57),
              fontSize: context.isPhone ? 18 : 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(axisValues.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == axisValues.length - 1 ? 0 : 20,
                    ),
                    child: _AxisLabel('${axisValues[index]}'),
                  );
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(points.length, (index) {
                    final point = points[index];
                    return _BarColumn(
                      label: _compactDateLabel(point.date),
                      value: effectiveMax == 0 ? 0 : point.kcal / effectiveMax,
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white54),
        ],
      ),
    );
  }

  static String _compactDateLabel(DateTime date) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[date.weekday - 1];
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: const TextStyle(
        color: Color(0xFFE7FF57),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: context.isPhone ? 16 : 26,
          height: context.isPhone ? 128 : 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 16,
            height: 128 * value,
            decoration: BoxDecoration(
              color: const Color(0xFFE7FF57),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE7FF57),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.summary,
  });

  final _DaySummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF6E89F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              title: 'Day',
              value: summary.weekday,
            ),
          ),
          const _SummaryDivider(),
          Expanded(
            child: _SummaryItem(
              title: 'Kcal',
              value: '${summary.totalKcal}',
            ),
          ),
          const _SummaryDivider(),
          Expanded(
            child: _SummaryItem(
              title: 'Duration',
              value: _formatSummaryDuration(summary.totalDurationSeconds),
              icon: Icons.watch_later_outlined,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatSummaryDuration(int durationSeconds) {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    if (hours == 0 && minutes == 0) {
      return '${durationSeconds}s';
    }
    if (hours == 0) {
      return '${minutes}m';
    }
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.value,
    this.icon,
  });

  final String title;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.isPhone ? 14 : 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        if (icon == null)
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.isPhone ? 20 : 30,
              fontWeight: FontWeight.w800,
            ),
          )
        else
          Row(
            children: [
              const Icon(Icons.watch_later_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.isPhone ? 16 : 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 1 : 2,
      height: context.isPhone ? 44 : 60,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: Colors.white54,
    );
  }
}

class _DailyKcalPoint {
  const _DailyKcalPoint({
    required this.date,
    required this.kcal,
  });

  final DateTime date;
  final int kcal;
}

class _DaySummary {
  const _DaySummary({
    required this.weekday,
    required this.totalKcal,
    required this.totalDurationSeconds,
  });

  final String weekday;
  final int totalKcal;
  final int totalDurationSeconds;
}
