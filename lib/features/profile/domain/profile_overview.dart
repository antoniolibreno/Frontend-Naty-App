import '../../training/domain/training.dart';

class ProfileOverview {
  const ProfileOverview(this.sections);
  final List<TrainingSection> sections;

  int get completedLessons =>
      sections.fold(0, (sum, section) => sum + section.progress.completed);
  int get totalLessons =>
      sections.fold(0, (sum, section) => sum + section.progress.total);
  int get completedTracks => sections
      .where(
        (section) =>
            section.progress.total > 0 &&
            section.progress.completed >= section.progress.total,
      )
      .length;
  double get progress =>
      totalLessons == 0 ? 0 : (completedLessons / totalLessons).clamp(0, 1);
  TrainingSection? get currentTrack {
    for (final section in sections) {
      if (!section.locked &&
          section.progress.total > section.progress.completed) {
        return section;
      }
    }
    return null;
  }
}
