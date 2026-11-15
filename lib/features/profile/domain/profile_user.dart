class ProfileUser {
  const ProfileUser({
    required this.name,
    required this.email,
    required this.company,
    required this.role,
    required this.level,
    required this.initials,
    required this.usageMinutes,
    required this.completedLessons,
    required this.totalLessons,
    required this.currentTrack,
    this.bio,
  });

  final String name;
  final String email;
  final String company;
  final String role;
  final String level;
  final String initials;
  final int usageMinutes;
  final int completedLessons;
  final int totalLessons;
  final String currentTrack;
  final String? bio;

  double get progress => totalLessons == 0 ? 0 : completedLessons / totalLessons;
  String get usageLabel {
    final hours = usageMinutes ~/ 60;
    final minutes = usageMinutes % 60;
    if (hours == 0) return '$minutes min';
    return minutes == 0 ? '$hours h' : '$hours h $minutes min';
  }
}
