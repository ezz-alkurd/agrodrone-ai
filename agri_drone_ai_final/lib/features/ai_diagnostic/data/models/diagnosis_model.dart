import '../../domain/entities/diagnosis_entity.dart';

class DiagnosisModel extends DiagnosisEntity {
  const DiagnosisModel({
    required super.diseaseName,
    required super.confidenceScore,
    required super.description,
    required super.treatment,
    required super.severity,
    required super.isHealthy,
    super.affectedAreas,
  });

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) => DiagnosisModel(
        diseaseName: json['diseaseName'] as String,
        confidenceScore: (json['confidenceScore'] as num).toDouble(),
        description: json['description'] as String,
        treatment: json['treatment'] as String,
        severity: DiseaseSeverity.values.byName(json['severity'] as String),
        isHealthy: json['isHealthy'] as bool,
        affectedAreas: List<String>.from(json['affectedAreas'] as List? ?? []),
      );

  // Mock responses returned by the stub AI endpoint
  static DiagnosisModel get mockDisease => const DiagnosisModel(
        diseaseName: 'Wheat Leaf Rust (Puccinia triticina)',
        confidenceScore: 0.91,
        description:
            'Leaf rust is a fungal disease producing orange-red pustules on the upper '
            'leaf surface. It spreads rapidly in warm, humid conditions and can cause '
            'significant yield loss if untreated.',
        treatment:
            '1. Apply Triazole-based fungicide (e.g., Propiconazole) at 0.5 L/ha.\n'
            '2. Ensure proper crop spacing to improve air circulation.\n'
            '3. Remove and destroy heavily infected plant material.\n'
            '4. Re-scout after 14 days; re-apply if infection persists.',
        severity: DiseaseSeverity.high,
        isHealthy: false,
        affectedAreas: ['Upper leaf surface', 'Stem nodes'],
      );

  static DiagnosisModel get mockHealthy => const DiagnosisModel(
        diseaseName: 'No Disease Detected',
        confidenceScore: 0.97,
        description: 'The crop appears healthy with no visible signs of disease, '
            'pest damage, or nutrient deficiency.',
        treatment: 'Continue regular monitoring and maintain current agronomic practices.',
        severity: DiseaseSeverity.none,
        isHealthy: true,
      );
}
