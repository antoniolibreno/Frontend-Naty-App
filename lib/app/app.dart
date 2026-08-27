import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/config/app_config.dart';
import '../core/di/injection.dart';
import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/home/presentation/bloc/home_event.dart';
import '../theme/app_colors.dart';

class NatyApp extends StatelessWidget {
  const NatyApp({required this.config, required this.router, super.key});

  final AppConfig config;
  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
      child: MaterialApp(
        title: config.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: AppColors.light.colorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: AppColors.dark.colorScheme,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        initialRoute: AppRoute.login.path,
        onGenerateRoute: router.generateRoute,
        onUnknownRoute: router.generateUnknownRoute,
      ),
    );
  }
}
