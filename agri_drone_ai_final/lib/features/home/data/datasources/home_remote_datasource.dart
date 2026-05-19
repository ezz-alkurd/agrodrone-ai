import '../models/drone_status_model.dart';

abstract class HomeRemoteDataSource {
  Future<DroneStatusModel> getDroneStatus();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<DroneStatusModel> getDroneStatus() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return DroneStatusModel.mock;
  }
}
