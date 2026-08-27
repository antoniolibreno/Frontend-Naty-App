enum AppRoute {
  home('/'),
  notFound('/not-found'),
  theo('/theo'),
  login('/login');
  const AppRoute(this.path);

  final String path;
}
