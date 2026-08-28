import 'dart:async';

import 'package:flutter/material.dart';
import 'package:natyapp/core/components/textFieldNaty.dart';
import 'package:natyapp/theme/app_colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AulaPage extends StatefulWidget {
  const AulaPage({
    super.key,
    this.videoId = '5g0fky3c1K0',
    this.title = 'Configuração Canais e Conexões',
    this.description =
        'Como configurar o número, validar o QR e direcionar cada canal para a fila certa.',
  });

  final String videoId;
  final String title;
  final String description;

  @override
  State<AulaPage> createState() => _AulaPageState();
}

class _AulaPageState extends State<AulaPage> {
  late final YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_youtubeController.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ColoredBox(
        color: AppColors.darkBackground,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  _buildHeader(),
                  _buildVideo(),
                  _buildDetails(),
                  _buildNotes(),
                ],
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 14,
              child: _buildQuizButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left),
          color: AppColors.darkTextSecondary,
          tooltip: 'Voltar',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        const SizedBox(width: 8),
        const Text(
          'Trilha 1 de 3',
          style: TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVideo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: _youtubeController,
          backgroundColor: AppColors.darkBackground,
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          widget.description,
          style: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ANOTAÇÕES',
              style: TextStyle(
                color: AppColors.darkTextDisabled,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Tirar dúvida',
              style: TextStyle(
                color: AppColors.brandGreen,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        _buildNoteRow(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Expanded(
              child: TextFieldNaty(
                onChanged: (value) {},
                hintText: 'Anotar neste minuto...',
              ),
            ),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkSurfaceVariant,
                  foregroundColor: AppColors.brandGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoteRow() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          spacing: 10,
          children: [
            Text(
              '01:12',
              style: TextStyle(
                color: AppColors.brandPurple,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: Text(
                'Urubu do pix > dentro dele',
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizButton() {
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.darkBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Ir para o quiz',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
