import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/usecases/analyze_image_usecase.dart';
import 'diagnostic_state.dart';

class DiagnosticCubit extends Cubit<DiagnosticState> {
  final AnalyzeImageUseCase _analyze;
  final ImagePicker _picker = ImagePicker();

  DiagnosticCubit(this._analyze) : super(const DiagnosticInitial());

  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    emit(DiagnosticImageSelected(File(picked.path)));
  }

  Future<void> analyzeCurrentImage() async {
    final current = state;
    if (current is! DiagnosticImageSelected) return;

    final image = current.image;
    emit(DiagnosticAnalyzing(image));

    final result = await _analyze(image);
    result.fold(
      (f) => emit(DiagnosticError(f.message)),
      (diagnosis) => emit(DiagnosticResult(image: image, diagnosis: diagnosis)),
    );
  }

  void reset() => emit(const DiagnosticInitial());
}
