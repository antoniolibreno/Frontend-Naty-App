import 'package:injectable/injectable.dart';
import 'package:natyapp/core/network/api_client.dart';

import '../domain/training.dart';

abstract interface class TrainingRepository {
  Future<List<TrainingTrack>> fetchTracks();
  Future<TrainingProgress> fetchProgress(String trackId);
  Future<TrainingActivity> fetchActivity(String activityId);
  Future<void> registerVideoStarted(String activityId);
  Future<void> registerVideoWatched(String activityId);
}

@LazySingleton(as: TrainingRepository)
class TrainingRepositoryApi implements TrainingRepository {
  TrainingRepositoryApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<TrainingTrack>> fetchTracks() async =>
      (await _apiClient.getList('/api/v1/trilhas'))
          .map((item) => TrainingTrack.fromJson(item as Map<String, dynamic>))
          .toList();

  @override
  Future<TrainingProgress> fetchProgress(String trackId) async =>
      TrainingProgress.fromJson(
        await _apiClient.getJson('/api/v1/trilhas/$trackId/progresso'),
      );

  @override
  Future<TrainingActivity> fetchActivity(String activityId) async =>
      TrainingActivity.fromJson(
        await _apiClient.getJson('/api/v1/atividades/$activityId'),
      );

  @override
  Future<void> registerVideoStarted(String activityId) async {
    await _apiClient.postJson('/api/v1/atividades/$activityId/video-iniciado');
  }

  @override
  Future<void> registerVideoWatched(String activityId) async {
    await _apiClient.postJson('/api/v1/atividades/$activityId/video-assistido');
  }
}
