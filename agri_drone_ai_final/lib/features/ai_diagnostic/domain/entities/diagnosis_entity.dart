import 'package:equatable/equatable.dart';

enum DiseaseSeverity { none, low, medium, high, critical }

class DiagnosisEntity extends Equatable {
  final String diseaseName;
  final double confidenceScore; // 0.0 – 1.0
  final String description;
  final String treatment;
  final DiseaseSeverity severity;
  final bool isHealthy;
  final List<String> affectedAreas;

  const DiagnosisEntity({
    required this.diseaseName,
    required this.confidenceScore,
    required this.description,
    required this.treatment,
    required this.severity,
    required this.isHealthy,
    this.affectedAreas = const [],
  });

  int get confidencePercent => (confidenceScore * 100).round();

  @override
  List<Object?> get props => [
        diseaseName,
        confidenceScore,
        description,
        treatment,
        severity,
        isHealthy,
        affectedAreas,
      ];
}
