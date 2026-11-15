import '../domain/profile_user.dart';

abstract class ProfileRepository {
  Future<ProfileUser> fetchProfile();
}

class ProfileRepositoryMock implements ProfileRepository {
  @override
  Future<ProfileUser> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const ProfileUser(
      name: 'Daniel Feliciano',
      email: 'daniel@naty.app',
      company: 'Naty Tecnologia',
      role: 'Administrador de atendimento',
      level: 'Intermediário',
      initials: 'DF',
      usageMinutes: 246,
      completedLessons: 4,
      totalLessons: 12,
      currentTrack: 'Implantação do atendimento',
      bio: 'Aprendendo a organizar o atendimento da equipe e cuidar melhor dos canais.',
    );
  }
}
