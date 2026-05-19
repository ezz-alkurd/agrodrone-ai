import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/diagnosis_entity.dart';
import '../../domain/repositories/diagnostic_repository.dart';
import '../datasources/diagnostic_remote_datasource.dart';

class DiagnosticRepositoryImpl implements DiagnosticRepository {
  final DiagnosticRemoteDataSource _remote;
  DiagnosticRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, DiagnosisEntity>> analyzeImage(File image) async {
    try {
      final result = await _remote.analyzeImage(image);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
