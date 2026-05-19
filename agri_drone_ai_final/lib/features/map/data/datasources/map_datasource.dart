import '../../domain/entities/map_marker_entity.dart';
import '../models/map_marker_model.dart';

abstract class MapDataSource {
  Future<List<MapMarkerModel>> getMarkers();
  Future<DronePathEntity> getDronePath();
}

class MapDataSourceImpl implements MapDataSource {
  @override
  Future<List<MapMarkerModel>> getMarkers() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return MapMarkerModel.mockMarkers;
  }

  @override
  Future<DronePathEntity> getDronePath() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MapMarkerModel.mockPath;
  }
}
