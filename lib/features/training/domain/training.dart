class TrainingTrack {
  const TrainingTrack({
    required this.id,
    required this.title,
    this.description,
  });

  factory TrainingTrack.fromJson(Map<String, dynamic> json) => TrainingTrack(
    id: json['id'] as String,
    title: (json['titulo'] ?? json['title']) as String,
    description: (json['descricao'] ?? json['description']) as String?,
  );

  final String id;
  final String title;
  final String? description;
}

class TrainingActivity {
  const TrainingActivity({
    required this.id,
    required this.title,
    required this.description,
    this.videoUrl,
    this.durationSeconds,
    required this.hasQuiz,
  });

  factory TrainingActivity.fromJson(Map<String, dynamic> json) =>
      TrainingActivity(
        id: json['id'] as String,
        title: (json['titulo'] ?? json['title']) as String,
        description: (json['descricao'] ?? json['description'] ?? '') as String,
        videoUrl: (json['videoUrl'] ?? json['video_url']) as String?,
        durationSeconds:
            (json['duracaoSegundos'] ?? json['durationSeconds']) as int?,
        hasQuiz: (json['possuiQuiz'] ?? json['hasQuiz'] ?? false) as bool,
      );

  final String id;
  final String title;
  final String description;
  final String? videoUrl;
  final int? durationSeconds;
  final bool hasQuiz;
}

class TrainingProgress {
  const TrainingProgress({
    required this.trackId,
    required this.completed,
    required this.total,
    this.nextActivityId,
    this.activities = const [],
  });

  factory TrainingProgress.fromJson(Map<String, dynamic> json) =>
      TrainingProgress(
        trackId: json['id'] as String,
        completed: (json['atividadesConcluidas'] as num).toInt(),
        total: (json['totalAtividades'] as num).toInt(),
        nextActivityId: json['proximaAtividadeId'] as String?,
        activities: ((json['modulos'] ?? const []) as List)
            .expand(
              (module) =>
                  ((module as Map<String, dynamic>)['atividades'] ?? const [])
                      as List,
            )
            .map(
              (item) => TrainingProgressActivity.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),
      );

  final String trackId;
  final int completed;
  final int total;
  final String? nextActivityId;
  final List<TrainingProgressActivity> activities;
}

class TrainingProgressActivity {
  const TrainingProgressActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.state,
  });

  factory TrainingProgressActivity.fromJson(Map<String, dynamic> json) =>
      TrainingProgressActivity(
        id: json['id'] as String,
        title: json['titulo'] as String,
        description: (json['descricao'] ?? '') as String,
        state: json['estado'] as String,
      );

  final String id;
  final String title;
  final String description;
  final String state;
}

/// Percurso ordenado: uma trilha abre quando todas as anteriores terminam.
class TrainingSection {
  const TrainingSection({
    required this.track,
    required this.progress,
    required this.locked,
  });
  final TrainingTrack track;
  final TrainingProgress progress;
  final bool locked;

  static List<TrainingSection> sequence(
    List<TrainingTrack> tracks,
    List<TrainingProgress> progress,
  ) {
    final byId = {for (final item in progress) item.trackId: item};
    final sections = <TrainingSection>[];
    var previousCompleted = true;
    for (final track in tracks) {
      final current = byId[track.id]!;
      sections.add(
        TrainingSection(
          track: track,
          progress: current,
          locked: !previousCompleted,
        ),
      );
      previousCompleted =
          previousCompleted &&
          current.total > 0 &&
          current.completed >= current.total;
    }
    return sections;
  }
}
