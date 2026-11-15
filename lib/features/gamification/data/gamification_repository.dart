import 'package:natyapp/core/network/api_client.dart';
import '../domain/gamification.dart';

abstract interface class GamificationRepository {
  Future<Gamification> fetchSummary(String memberId);
  Future<RankingPage> fetchRanking({int page = 0, int size = 20});
}

class GamificationRepositoryApi implements GamificationRepository {
  GamificationRepositoryApi(this._api);
  final ApiClient _api;

  @override
  Future<Gamification> fetchSummary(String memberId) async =>
      Gamification.fromJson(
        await _api.getJson(
          '/api/v1/integrantes/${Uri.encodeComponent(memberId)}/gamificacao',
        ),
      );

  @override
  Future<RankingPage> fetchRanking({int page = 0, int size = 20}) async =>
      RankingPage.fromJson(
        // O Pageable da aplicação usa os nomes configurados em application.yml.
        await _api.getJson('/api/v1/ranking?pagina=$page&tamanho=$size'),
      );
}
