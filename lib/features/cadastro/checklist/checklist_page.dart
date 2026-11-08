import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/back_title_header.dart';
import '../../../core/widgets/gradient_button.dart';
import '../cadastro_strings.dart';
import 'checklist_controller.dart';
import 'checklist_models.dart';
import 'widgets/checklist_tile.dart';

/// Tela 4 da jornada de cadastro: checklist de configuração da trilha.
class ChecklistPage extends StatefulWidget {
  const ChecklistPage({
    super.key,
    required this.trilha,
    required this.salvar,
    required this.onConcluido,
    this.marcadosIniciais = const {},
  });

  final TrilhaChecklist trilha;
  final SalvarChecklist salvar;
  final VoidCallback onConcluido;

  /// Itens já marcados anteriormente (ex.: vindos do backend).
  final Set<String> marcadosIniciais;

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  late final ChecklistController _controller = ChecklistController(
    trilha: widget.trilha,
    salvar: widget.salvar,
    marcadosIniciais: widget.marcadosIniciais,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _concluir() async {
    final ok = await _controller.concluir();
    if (!mounted) return;

    if (ok) {
      widget.onConcluido();
    } else if (_controller.erro != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(_controller.erro!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trilha;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.formHorizontal,
                  0,
                ),
                child: BackTitleHeader(
                  label: ChecklistStrings.trilhaDe(t.numero, t.totalTrilhas),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.formHorizontal,
                    AppSpacing.xl,
                    AppSpacing.formHorizontal,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ChecklistStrings.titulo, style: AppTextStyles.title),
                      const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
                      Text(ChecklistStrings.subtitulo, style: AppTextStyles.subtitle),
                      const SizedBox(height: AppSpacing.lg),
                      if (_controller.vazio)
                        const _EstadoVazio()
                      else
                        for (final item in t.itens)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: ChecklistTile(
                              item: item,
                              marcado: _controller.marcado(item.id),
                              onChanged: _controller.salvando
                                  ? null
                                  : () => _controller.alternar(item.id),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.formHorizontal,
                  AppSpacing.sm,
                  AppSpacing.formHorizontal,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    if (!_controller.vazio) ...[
                      Text(
                        ChecklistStrings.contador(
                          _controller.totalMarcados,
                          _controller.totalItens,
                        ),
                        style: AppTextStyles.counter.copyWith(letterSpacing: 0),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    GradientButton(
                      label: ChecklistStrings.concluir(t.numero),
                      isLoading: _controller.salvando,
                      // No Figma o botão fica ativo mesmo com 1/4 marcados.
                      onPressed: _concluir,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Text(
          ChecklistStrings.vazio,
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle,
        ),
      ),
    );
  }
}
