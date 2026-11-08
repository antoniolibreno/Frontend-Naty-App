import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:natyapp/core/router/app_routes.dart';
import 'package:natyapp/theme/app_colors.dart';

import '../../domain/resumo_conclusao.dart';
import '../bloc/conclusao_bloc.dart';
import '../bloc/conclusao_event.dart';
import '../bloc/conclusao_state.dart';
import '../widgets/estado_carregamento.dart';
import '../widgets/rotulo_secao.dart';

/// Tela "Implantação concluída": selo do integrante e próximos passos.
///
/// Espera um [ConclusaoBloc] acima dela na árvore (o `AppRouter` fornece).
class ConclusaoPage extends StatelessWidget {
  const ConclusaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand: o Scaffold entrega altura frouxa ao body, e sem ele o
    // fundo só cobre a altura do conteúdo.
    return ColoredBox(
      color: AppColors.darkBackground,
      child: SizedBox.expand(
        child: SafeArea(
          child: BlocBuilder<ConclusaoBloc, ConclusaoState>(
            builder: (context, state) => switch (state) {
              ConclusaoInicial() ||
              ConclusaoCarregando() => const CarregandoConteudo(),
              ConclusaoFalha(:final message) => FalhaCarregamento(
                mensagem: message,
                onTentarNovamente: () => context.read<ConclusaoBloc>().add(
                  const ConclusaoSolicitada(),
                ),
              ),
              ConclusaoCarregada(:final resumo) => _Conteudo(resumo: resumo),
            },
          ),
        ),
      ),
    );
  }
}

void _avisarEmBreve(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('Em breve'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.resumo});

  final ResumoConclusao resumo;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Saudacao(resumo: resumo),
          const SizedBox(height: 32),
          _CartaoSelo(resumo: resumo),
          const SizedBox(height: 32),
          const RotuloSecao('Continuar evoluindo'),
          const SizedBox(height: 8),
          _ItemContinuar(
            icone: Icons.description_outlined,
            corIcone: AppColors.brandGreen,
            titulo: 'Relatório da implantação',
            subtitulo: 'Resumo para enviar ao gestor',
            onTap: () => _avisarEmBreve(context),
          ),
          _ItemContinuar(
            icone: Icons.videocam_outlined,
            corIcone: AppColors.primaryLight,
            titulo: 'Trilha avançada: chatbot',
            subtitulo: '4 vídeos · 12 min',
            onTap: () => _avisarEmBreve(context),
          ),
          _ItemContinuar(
            icone: Icons.chat_bubble_outline,
            corIcone: AppColors.darkTextSecondary,
            titulo: 'Falar com a Naty',
            subtitulo: 'Dúvidas sobre o dia a dia',
            onTap: () => _avisarEmBreve(context),
          ),
        ],
      ),
    );
  }
}

class _Saudacao extends StatelessWidget {
  const _Saudacao({required this.resumo});

  final ResumoConclusao resumo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                'Olá, ${resumo.primeiroNome}',
                style: const TextStyle(
                  color: AppColors.darkTextDisabled,
                  fontSize: 14,
                ),
              ),
              Semantics(
                header: true,
                child: const Text(
                  'Implantação concluída',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ExcludeSemantics(
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Text(
              resumo.iniciais,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartaoSelo extends StatelessWidget {
  const _CartaoSelo({required this.resumo});

  final ResumoConclusao resumo;

  @override
  Widget build(BuildContext context) {
    const divisoria = Divider(
      height: 1,
      thickness: 1,
      color: AppColors.darkBorder,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    size: 22,
                    color: AppColors.brandGreen,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Ambiente pronto para atender',
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nº ${resumo.numeroSelo.toString().padLeft(4, '0')}',
                    style: const TextStyle(
                      color: AppColors.darkTextDisabled,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            divisoria,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                children: [
                  _LinhaResumo(
                    rotulo: 'Trilhas',
                    valor:
                        '${resumo.trilhasConcluidas} de ${resumo.totalTrilhas}',
                  ),
                  _LinhaResumo(
                    rotulo: 'Quizzes',
                    valor:
                        '${resumo.quizzesRealizados} · '
                        '${resumo.percentualAcertoQuiz}%',
                  ),
                  _LinhaResumo(
                    rotulo: 'Itens de configuração',
                    valor: '${resumo.itensConfiguracao}',
                  ),
                  _LinhaResumo(
                    rotulo: 'Emitido em',
                    valor: formatarDataCurta(resumo.emitidoEm),
                  ),
                ],
              ),
            ),
            divisoria,
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _AcaoDoCartao(
                      icone: Icons.share_outlined,
                      rotulo: 'Compartilhar selo',
                      cor: AppColors.brandGreen,
                      peso: FontWeight.w600,
                      onTap: () => _avisarEmBreve(context),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: AppColors.darkBorder),
                  Expanded(
                    child: _AcaoDoCartao(
                      icone: Icons.show_chart,
                      rotulo: 'Ver progresso',
                      cor: AppColors.darkTextSecondary,
                      peso: FontWeight.w500,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoute.progresso.path),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaResumo extends StatelessWidget {
  const _LinhaResumo({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$rotulo: $valor',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        // Rótulo e valor só encolhem (com "…") quando não cabem, como em
        // tela estreita ou fonte do sistema aumentada; a linha do meio
        // ocupa sempre o espaço que sobra.
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.55,
                ),
                child: Text(
                  rotulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkTextDisabled,
                    fontSize: 14,
                  ),
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.darkBorder,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.35,
                ),
                child: Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AcaoDoCartao extends StatelessWidget {
  const _AcaoDoCartao({
    required this.icone,
    required this.rotulo,
    required this.cor,
    required this.peso,
    required this.onTap,
  });

  final IconData icone;
  final String rotulo;
  final Color cor;
  final FontWeight peso;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 18, color: cor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  rotulo,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cor, fontSize: 15, fontWeight: peso),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemContinuar extends StatelessWidget {
  const _ItemContinuar({
    required this.icone,
    required this.corIcone,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  final IconData icone;
  final Color corIcone;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.darkBorder)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Icon(icone, size: 22, color: corIcone),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          color: AppColors.darkTextDisabled,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.darkTextDisabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _mesesAbreviados = [
  'jan',
  'fev',
  'mar',
  'abr',
  'mai',
  'jun',
  'jul',
  'ago',
  'set',
  'out',
  'nov',
  'dez',
];

/// Formata a data no padrão do design, ex.: "14 ago 2026".
String formatarDataCurta(DateTime data) =>
    '${data.day} ${_mesesAbreviados[data.month - 1]} ${data.year}';
