import 'package:natyapp/core/network/api_client.dart';

import '../domain/progresso_repository.dart';
import '../domain/resumo_conclusao.dart';
import '../domain/resumo_progresso.dart';

/// Implementação que lê os dados reais da API.
///
/// Ainda NÃO está registrada no get_it: o app usa `ProgressoRepositoryMock`
/// porque o back não expõe esses dados e o `ApiClient` ainda não faz
/// requisições. Para ligar, quando o back estiver pronto:
///
/// 1. Confirmar com o back os caminhos e campos de `docs/contrato-progresso.md`.
/// 2. Trocar o corpo de [_buscarJson] pelo GET autenticado do `ApiClient`
///    (com o token da sessão, que vem da feature de login).
/// 3. Mover a anotação `@LazySingleton(as: ProgressoRepository)` do mock para
///    esta classe e rodar
///    `dart run build_runner build --delete-conflicting-outputs`.
///
/// As telas e os blocs não mudam.
class ProgressoRepositoryApi implements ProgressoRepository {
  ProgressoRepositoryApi(this._apiClient);

  static const caminhoResumo = '/api/v1/progresso/resumo';
  static const caminhoConclusao = '/api/v1/progresso/conclusao';

  final ApiClient _apiClient;

  @override
  Future<ResumoProgresso> buscarResumo() async =>
      ResumoProgresso.fromJson(await _buscarJson(caminhoResumo));

  @override
  Future<ResumoConclusao> buscarConclusao() async =>
      ResumoConclusao.fromJson(await _buscarJson(caminhoConclusao));

  Future<Map<String, dynamic>> _buscarJson(String caminho) async {
    throw UnimplementedError(
      'GET ${_apiClient.config.baseUrl}$caminho ainda não está ligado: '
      'o ApiClient não faz requisições HTTP.',
    );
  }
}
