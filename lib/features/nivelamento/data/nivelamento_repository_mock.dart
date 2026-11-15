import '../../quiz/domain/quiz_result.dart';
import '../domain/nivelamento_result.dart';

abstract class NivelamentoRepository {
  Future<NivelamentoResult> calculate(QuizResult result);
}

class NivelamentoRepositoryMock implements NivelamentoRepository {
  @override
  Future<NivelamentoResult> calculate(QuizResult result) async {
    final ratio = result.total == 0 ? 0.0 : result.score / result.total;
    final level = ratio >= .8 ? 'avançado' : ratio >= .5 ? 'intermediário' : 'iniciante';
    return NivelamentoResult(quizResult: result, level: level, recommendedTrackId: ratio >= .8 ? 'trilha-3' : ratio >= .5 ? 'trilha-2' : 'trilha-1');
  }
}
