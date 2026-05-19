import 'dart:io';
import '../models/diagnosis_model.dart';

abstract class DiagnosticRemoteDataSource {
  Future<DiagnosisModel> analyzeImage(File image);
}

/// Stub — replace body with multipart Dio POST to your AI backend.
class DiagnosticRemoteDataSourceImpl implements DiagnosticRemoteDataSource {
  @override
  Future<DiagnosisModel> analyzeImage(File image) async {
    // Simulate network + inference time
    await Future.delayed(const Duration(seconds: 3));

    // Toggle between mock responses based on file size parity (demo only)
    final sizeKb = await image.length() ~/ 1024;
    return sizeKb.isEven ? DiagnosisModel.mockDisease : DiagnosisModel.mockHealthy;
  }
}
