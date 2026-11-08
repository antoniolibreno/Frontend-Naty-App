enum AppRoute {
  home('/'),
  notFound('/not-found'),
  theo('/theo'),
  login('/login'),
  aula('/aula'),
  cadastro('/cadastro');
  const AppRoute(this.path);

  final String path;
}
