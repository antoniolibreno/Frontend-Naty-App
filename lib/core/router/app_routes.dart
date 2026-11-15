enum AppRoute {
  home('/'),
  notFound('/not-found'),
  profile('/profile'),
  login('/login'),
  quiz('/quiz'),
  aula('/aula'),
  progresso('/progresso'),
  conclusao('/conclusao');

  const AppRoute(this.path);

  final String path;
}
