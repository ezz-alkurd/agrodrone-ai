import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../cubit/diagnostic_cubit.dart';
import '../cubit/diagnostic_state.dart';
import '../widgets/result_card.dart';
import '../widgets/upload_section.dart';

class AiDiagnosticPage extends StatelessWidget {
  const AiDiagnosticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: const Text('AI Plant Diagnosis'),
        actions: [
          BlocBuilder<DiagnosticCubit, DiagnosticState>(
            builder: (ctx, state) {
              if (state is DiagnosticResult || state is DiagnosticError) {
                return IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => ctx.read<DiagnosticCubit>().reset(),
                  tooltip: 'Start over',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<DiagnosticCubit, DiagnosticState>(
        builder: (ctx, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderBanner(),
                const SizedBox(height: AppDimensions.spaceLG),
                if (state is DiagnosticInitial)
                  UploadSection(
                    selectedImage: null,
                    onCamera: () => ctx.read<DiagnosticCubit>().pickImage(ImageSource.camera),
                    onGallery: () => ctx.read<DiagnosticCubit>().pickImage(ImageSource.gallery),
                    canAnalyze: false,
                  ),
                if (state is DiagnosticImageSelected)
                  UploadSection(
                    selectedImage: state.image,
                    onCamera: () => ctx.read<DiagnosticCubit>().pickImage(ImageSource.camera),
                    onGallery: () => ctx.read<DiagnosticCubit>().pickImage(ImageSource.gallery),
                    canAnalyze: true,
                    onAnalyze: () => ctx.read<DiagnosticCubit>().analyzeCurrentImage(),
                  ),
                if (state is DiagnosticAnalyzing) ...[
                  _ImagePreview(image: state.image),
                  const SizedBox(height: AppDimensions.spaceMD),
                  _AnalyzingShimmer(),
                ],
                if (state is DiagnosticResult) ...[
                  _ImagePreview(image: state.image),
                  const SizedBox(height: AppDimensions.spaceMD),
                  const Text(
                    'Analysis Result',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceSM),
                  ResultCard(diagnosis: state.diagnosis),
                ],
                if (state is DiagnosticError)
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceMD),
                    decoration: BoxDecoration(
                      color: AppColors.alertFireFaint,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                      border: Border.all(color: AppColors.alertFire.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.alertFire),
                        const SizedBox(width: AppDimensions.spaceSM),
                        Expanded(
                          child: Text(state.message,
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppDimensions.spaceXL),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C2333), Color(0xFF21262D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.borderDim),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceSM),
            decoration: BoxDecoration(
              color: const Color(0x267C3AED),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: const Icon(Icons.biotech_outlined, color: Color(0xFF7C3AED), size: 24),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Plant Scanner',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    )),
                SizedBox(height: 2),
                Text('Upload or capture a crop photo to detect disease instantly',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File image;
  const _ImagePreview({required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: Image.file(image, height: 200, width: double.infinity, fit: BoxFit.cover),
    );
  }
}

class _AnalyzingShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.neonGreen),
            ),
            SizedBox(width: AppDimensions.spaceSM),
            Text('Analyzing image with AI model...',
                style: TextStyle(color: AppColors.neonGreen, fontSize: 13)),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Shimmer.fromColors(
          baseColor: AppColors.backgroundCard,
          highlightColor: AppColors.backgroundElevated,
          child: Column(
            children: List.generate(
              4,
              (_) => Container(
                height: 18,
                margin: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
