import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:home_fitness/screen/info_user.dart';
import 'package:home_fitness/screen/tabbar/cycling_screen.dart';
import 'package:home_fitness/screen/edit_profile_screen.dart';
import 'package:home_fitness/screen/exercise_detail_screen.dart';
import 'package:home_fitness/screen/tabbar/setting_screen.dart';
import 'package:home_fitness/screen/workout_detail_screen.dart';
import 'package:home_fitness/screen/tabbar/workout_screen.dart';
import '../model/workout_models.dart';
import '../screen/tabbar/home_screen.dart';
import 'app_routes.dart';
import 'main_scaffold.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter({
  required bool hasProfile,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: hasProfile ? AppRoutes.home : AppRoutes.infoUser,

    routes: [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.infoUser,
        builder: (context, state) => const InfoUser(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.workoutDetail,
        builder: (context, state) => const WorkoutDetailScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.workoutExercise,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is ExerciseDetailArgs) {
            return ExerciseDetailScreen(
              exercise: extra.exercise,
              initialElapsedSeconds: extra.elapsedSeconds,
              initialCompletedExercises: extra.completedExercises,
            );
          }

          final exercise = extra as WorkoutExercise;
          return ExerciseDetailScreen(exercise: exercise);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.workout,
                builder: (context, state) => const WorkoutScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cycling,
                builder: (context, state) => const CyclingScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.setting,
                builder: (context, state) => const SettingScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
