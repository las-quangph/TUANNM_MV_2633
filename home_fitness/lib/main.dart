import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:home_fitness/route/app_route.dart';

import 'bloc/home/workout_activity/workout_activity_bloc.dart';
import 'bloc/home/workout_activity/workout_activity_event.dart';
import 'common/storage/user_profile_storage.dart';

const _appOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  SystemChrome.setSystemUIOverlayStyle(_appOverlayStyle);

  final hasProfile = await UserProfileStorage.hasProfile();

  runApp(MyApp(hasProfile: hasProfile));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.hasProfile,
  });

  final bool hasProfile;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(hasProfile: widget.hasProfile);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => WorkoutActivityBloc()..add(const LoadWorkoutActivities()),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        builder: (context, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: _appOverlayStyle,
            child: child ?? const SizedBox.shrink(),
          );
        },
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: _appOverlayStyle,
          ),
        ),
      ),
    );
  }
}
