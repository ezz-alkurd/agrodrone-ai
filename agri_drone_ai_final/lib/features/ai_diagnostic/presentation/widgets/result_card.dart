import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/diagnosis_entity.dart';

class ResultCard extends StatelessWidget {
  final DiagnosisEntity diagnosis;

  const ResultCard({super.key, required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    final isHealthy = diagnosis.isHealthy;
    final accentColor = isHealthy ? AppColors.neonGreen : AppColors.alertDisease;
    final faintColor  = isHealthy ? AppColors.neonGreenFaint : AppColors.alertDiseaseFaint;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: faintColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: accentColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: accentColor,
                size: 22,
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              Expanded(
                child: Text(
                  diagnosis.diseaseName,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _SeverityBadge(severity: diagnosis.severity),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          // Confidence bar
          _ConfidenceBar(score: diagnosis.confidenceScore, color: accentColor),
          const SizedBox(height: AppDimensions.spaceMD),

          // Description
          Text(
            diagnosis.description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
          ),

          if (!isHealthy) ...[
            const SizedBox(height: AppDimensions.spaceMD),
            const Divider(color: AppColors.borderDim),
            const SizedBox(height: AppDimensions.spaceSM),
            const Row(
              children: [
                Icon(Icons.local_pharmacy_outlined, color: AppColors.neonGreen, size: 16),
                SizedBox(width: AppDimensions.spaceSM),
                Text('Recommended Treatment',
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              diagnosis.treatment,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.6),
            ),
          ],

          if (diagnosis.affectedAreas.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spaceMD),
            Wrap(
              spacing: AppDimensions.spaceSM,
              children: diagnosis.affectedAreas
                  .map((a) => Chip(
                        label: Text(a,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11)),
                        backgroundColor: AppColors.backgroundElevated,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: const BorderSide(color: AppColors.borderDim),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  final double score;
  final Color color;

  const _ConfidenceBar({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Confidence',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const Spacer(),
            Text('${(score * 100).round()}%',
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score,
            backgroundColor: AppColors.borderDim,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final DiseaseSeverity severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    if (severity == DiseaseSeverity.none) return const SizedBox.shrink();

    final (label, color) = switch (severity) {
      DiseaseSeverity.low      => ('LOW',      AppColors.neonGreen),
      DiseaseSeverity.medium   => ('MEDIUM',   AppColors.alertDisease),
      DiseaseSeverity.high     => ('HIGH',      AppColors.alertFire),
      DiseaseSeverity.critical => ('CRITICAL', AppColors.alertFire),
      DiseaseSeverity.none     => ('',          Colors.transparent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }
}
