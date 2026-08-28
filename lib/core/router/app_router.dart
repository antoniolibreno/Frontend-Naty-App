import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:natyapp/core/router/ProgressBar.dart';
import 'package:natyapp/features/aula/presentation/pages/aula.dart';
import 'package:natyapp/features/home/presentation/pages/home.dart';
import 'package:natyapp/features/login/presentation/pages/login.dart';
import 'package:natyapp/features/theo/presentation/pages/theo.dart';
import 'package:natyapp/theme/theme.dart';

import 'app_routes.dart';

class AppRouter {
  const AppRouter();

  Route<dynamic> generateRoute(RouteSettings settings) {
    final route = _routeFromPath(settings.name) ?? AppRoute.notFound;

    switch (route) {
      case AppRoute.home:
        final color = settings.arguments is Color
            ? settings.arguments! as Color
            : AppColors.brandPurple;

        return _pageRoute(HomePage(color: color), settings, route);
      case AppRoute.notFound:
        return _pageRoute(const _NotFoundPage(), settings, route);
      case AppRoute.theo:
        return _pageRoute(const TheoPage(), settings, route);
      case AppRoute.aula:
        return _pageRoute(const AulaPage(), settings, route);
      case AppRoute.login:
        return _pageRoute(const LoginPage(), settings, route);
    }
  }

  Route<dynamic> generateUnknownRoute(RouteSettings settings) {
    return _pageRoute(const _NotFoundPage(), settings, AppRoute.notFound);
  }

  AppRoute? _routeFromPath(String? path) {
    for (final route in AppRoute.values) {
      if (route.path == path) {
        return route;
      }
    }
    return null;
  }

  PageRoute<T> _pageRoute<T>(
    Widget page,
    RouteSettings settings,
    AppRoute route,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: _HomeBasePage(rotaAtual: route, child: child),
        );
      },
    );
  }
}

class _HomeBasePage extends StatelessWidget {
  const _HomeBasePage({required this.child, required this.rotaAtual});

  final Widget child;
  final AppRoute rotaAtual;

  bool mostrarSideBar() {
    return {AppRoute.home, AppRoute.theo}.contains(rotaAtual);
  }

  int get _selectedIndex => switch (rotaAtual) {
    AppRoute.home => 0,
    AppRoute.theo => 1,
    _ => 0,
  };

  void _onDestinationSelected(BuildContext context, int index) {
    final destination = switch (index) {
      0 => AppRoute.home,
      1 => AppRoute.theo,
      _ => AppRoute.home,
    };

    if (destination == rotaAtual) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(destination.path);
  }

  @override
  Widget build(BuildContext context) {
    if (!mostrarSideBar()) {
      return Scaffold(body: child);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 600;
        final mediaPadding = MediaQuery.paddingOf(context);

        if (useRail) {
          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(child: child),
                Positioned(
                  left: 16,
                  top: mediaPadding.top + 16,
                  bottom: mediaPadding.bottom + 16,

                  child: _GlassNavigation(
                    child: _IconNavigation(
                      selectedIndex: _selectedIndex,
                      vertical: true,
                      onSelected: (index) {
                        _onDestinationSelected(context, index);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }

          return Scaffold(
            body: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: mediaPadding.top ),
                    if (rotaAtual == AppRoute.home) const Progressbar(),
                    Expanded(child: child),
                  ],
                ),

                Positioned(
                left: 20,
                right: 20,
                bottom: mediaPadding.bottom + 16,
                height: 60,

                child: _GlassNavigation(
                  child: _IconNavigation(
                    selectedIndex: _selectedIndex,
                    onSelected: (index) {
                      _onDestinationSelected(context, index);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IconNavigation extends StatelessWidget {
  const _IconNavigation({
    required this.selectedIndex,
    required this.onSelected,
    this.vertical = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool vertical;

  static const _items = [
    (label: 'Início', icon: Icons.home_outlined, selectedIcon: Icons.home),
    (label: 'Perfil', icon: Icons.person_outline, selectedIcon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final buttons = [
      for (var index = 0; index < _items.length; index++)
        Semantics(
          button: true,
          selected: selectedIndex == index,
          label: _items[index].label,
          child: IconButton(
            tooltip: _items[index].label,
            onPressed: () => onSelected(index),
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: selectedIndex == index
                  ? colors.primary
                  : colors.onSurfaceVariant,
              backgroundColor: selectedIndex == index
                  ? colors.primary.withValues(alpha: 0.16)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(
              selectedIndex == index
                  ? _items[index].selectedIcon
                  : _items[index].icon,
              size: 24,
            ),
          ),
        ),
    ];

    return vertical
        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: buttons)
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buttons,
          );
  }
}

class _GlassNavigation extends StatelessWidget {
  const _GlassNavigation({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.outline.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Página não encontrada',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
