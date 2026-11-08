import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:natyapp/core/router/app_routes.dart';
import 'package:natyapp/theme/app_colors.dart';

import '../../domain/resumo_progresso.dart';
import '../bloc/progresso_bloc.dart';
import '../bloc/progresso_event.dart';
import '../bloc/progresso_state.dart';
import '../widgets/estado_carregamento.dart';
import '../widgets/rotulo_secao.dart';

/// Tela "Seu progresso": XP, nível, indicadores e conquistas do integrante.
///
/// Espera um [ProgressoBloc] acima dela na árvore (o `AppRouter` fornece).
class ProgressoPage extends StatelessWidget {
  const ProgressoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand: o Scaffold entrega altura frouxa ao body, e sem ele o
    // fundo só cobre a altura do conteúdo.
    return ColoredBox(
      color: AppColors.darkBackground,
      child: SizedBox.expand(
        child: SafeArea(
          child: BlocConsumer<ProgressoBloc, ProgressoState>(
            listenWhen: (_, atual) =>
                atual is ProgressoCarregado && atual.falhaAtualizacao != null,
            listener: (context, state) {
              final mensagem = (state as ProgressoCarregado).falhaAtualizacao;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(mensagem!),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
            builder: (context, state) => switch (state) {
              ProgressoInicial() || ProgressoCarregando() => const Column(
                children: [
                  _Cabecalho(),
                  Expanded(child: CarregandoConteudo()),
                ],
              ),
              ProgressoFalha(:final message) => Column(
                children: [
                  const _Cabecalho(),
                  Expanded(
                    child: FalhaCarregamento(
                      mensagem: message,
                      onTentarNovamente: () => context
                          .read<ProgressoBloc>()
                          .add(const ProgressoSolicitado()),
                    ),
                  ),
                ],
              ),
              ProgressoCarregado(:final resumo) => _Conteudo(resumo: resumo),
            },
          ),
        ),
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.resumo});

  final ResumoProgresso resumo;

  /// Pede a atualização e espera o bloc responder, para o indicador de
  /// "puxar para atualizar" sumir só quando os dados (ou o erro) chegarem.
  Future<void> _atualizar(BuildContext context) async {
    final bloc = context.read<ProgressoBloc>();
    final resposta = bloc.stream
        .firstWhere(
          (state) => state is ProgressoCarregado || state is ProgressoFalha,
        )
        .timeout(const Duration(seconds: 30), onTimeout: () => bloc.state);
    bloc.add(const ProgressoAtualizacaoSolicitada());
    await resposta;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.brandGreen,
      backgroundColor: AppColors.darkSurface,
      onRefresh: () => _atualizar(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Cabecalho(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  _Nivel(resumo: resumo),
                  const SizedBox(height: 24),
                  _Indicadores(resumo: resumo),
                  const SizedBox(height: 32),
                  const RotuloSecao('Conquistas'),
                  const SizedBox(height: 4),
                  for (final conquista in resumo.conquistas)
                    _LinhaConquista(conquista: conquista),
                  const SizedBox(height: 24),
                  const _VoltarParaHome(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.chevron_left),
            iconSize: 22,
            color: AppColors.darkTextSecondary,
            tooltip: 'Voltar',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 32),
          ),
          const SizedBox(width: 12),
          const Text(
            'Seu progresso',
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Nivel extends StatelessWidget {
  const _Nivel({required this.resumo});

  final ResumoProgresso resumo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: '${resumo.xpTotal} XP',
          excludeSemantics: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${resumo.xpTotal}',
                style: const TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'XP',
                style: TextStyle(
                  color: AppColors.darkTextDisabled,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'NÍVEL ${resumo.nivel} · ${resumo.nomeNivel}',
          style: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 16),
        _BarraDoNivel(progresso: resumo.progressoNoNivel),
        const SizedBox(height: 12),
        Text(
          '${resumo.xpParaProximoNivel} XP para o próximo nível',
          style: const TextStyle(
            color: AppColors.darkTextDisabled,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _BarraDoNivel extends StatelessWidget {
  const _BarraDoNivel({required this.progresso});

  final double progresso;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Progresso no nível',
      value: '${(progresso * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          height: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.darkBorder),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progresso,
                child: const ColoredBox(color: AppColors.brandGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Indicadores extends StatelessWidget {
  const _Indicadores({required this.resumo});

  final ResumoProgresso resumo;

  @override
  Widget build(BuildContext context) {
    const divisoria = BorderSide(color: AppColors.darkBorder);

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: divisoria, bottom: divisoria),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: _Indicador(
                valor: '${resumo.diasSeguidos}',
                legenda: resumo.diasSeguidos == 1
                    ? 'dia seguido'
                    : 'dias seguidos',
                primeiro: true,
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.darkBorder),
            Expanded(
              flex: 8,
              child: _Indicador(
                valor: '${resumo.percentualAcertoQuiz}%',
                legenda: 'acerto nos quizzes',
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.darkBorder),
            Expanded(
              flex: 8,
              child: _Indicador(
                valor: '${resumo.trilhasConcluidas}/${resumo.totalTrilhas}',
                legenda: 'trilhas concluídas',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.valor,
    required this.legenda,
    this.primeiro = false,
  });

  final String valor;
  final String legenda;
  final bool primeiro;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(primeiro ? 0 : 16, 18, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            legenda,
            maxLines: 2,
            style: const TextStyle(
              color: AppColors.darkTextDisabled,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaConquista extends StatelessWidget {
  const _LinhaConquista({required this.conquista});

  final Conquista conquista;

  IconData get _icone => switch (conquista.tipo) {
    TipoConquista.primeiroCanal => Icons.bolt_outlined,
    TipoConquista.quizSemErro => Icons.track_changes,
    TipoConquista.sequenciaDias => Icons.local_fire_department_outlined,
    TipoConquista.implantacaoCompleta => Icons.workspace_premium_outlined,
    TipoConquista.outra => Icons.emoji_events_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final obtida = conquista.conquistada;
    final status = obtida
        ? 'Conquistada'
        : (conquista.pendencia ?? 'Bloqueada');

    return Semantics(
      label: '${conquista.titulo}, $status',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.darkBorder)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(
                _icone,
                size: 20,
                color: obtida
                    ? AppColors.brandGreen
                    : AppColors.darkTextDisabled,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  conquista.titulo,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: obtida
                        ? AppColors.darkTextPrimary
                        : AppColors.darkTextDisabled,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                status,
                style: TextStyle(
                  color: obtida
                      ? AppColors.darkTextDisabled
                      : AppColors.darkTextDisabled.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoltarParaHome extends StatelessWidget {
  const _VoltarParaHome();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoute.home.path, (_) => false),
        icon: const Icon(Icons.arrow_back, size: 18),
        label: const Text('Voltar para a home'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandGreen,
          padding: const EdgeInsets.symmetric(vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.padded,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
