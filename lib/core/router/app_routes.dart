enum AppRoute {
  home('/'),
  notFound('/not-found'),
  theo('/theo'),
  login('/login'),
  aula('/aula');
  const AppRoute(this.path);

  final String path;
}
