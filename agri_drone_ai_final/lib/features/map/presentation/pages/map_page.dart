import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';
import '../widgets/map_legend.dart';

/// Stylized placeholder map.
///
/// Renders the drone flight path and detection markers on a synthetic
/// dark grid so the screen is functional without a Google Maps API key.
/// To swap in a real map later, replace this widget's body with a
/// `GoogleMap` from `google_maps_flutter` and re-add the dependency
/// to `pubspec.yaml`.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    super.initState();
    context.read<MapCubit>().loadMapData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(title: const Text('Live Map')),
      body: BlocBuilder<MapCubit, MapState>(
        builder: (ctx, state) {
          if (state is MapLoading || state is MapInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.neonGreen),
            );
          }
          if (state is MapError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: AppColors.alertFire)),
            );
          }
          if (state is MapLoaded) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapPainter(
                      markers: state.markers,
                      path: state.path,
                    ),
                  ),
                ),
                const Positioned(
                  left: AppDimensions.spaceMD,
                  bottom: AppDimensions.spaceLG,
                  child: MapLegend(),
                ),
                Positioned(
                  right: AppDimensions.spaceMD,
                  bottom: AppDimensions.spaceLG,
                  child: FloatingActionButton.small(
                    backgroundColor: AppColors.backgroundCard,
                    onPressed: () =>
                        context.read<MapCubit>().loadMapData(),
                    child: const Icon(Icons.refresh_rounded,
                        color: AppColors.neonGreen),
                  ),
                ),
                Positioned(
                  top: AppDimensions.spaceMD,
                  left: AppDimensions.spaceMD,
                  right: AppDimensions.spaceMD,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceMD,
                      vertical: AppDimensions.spaceSM,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard.withOpacity(0.92),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMD),
                      border: Border.all(color: AppColors.borderDim),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: AppDimensions.spaceSM),
                        Expanded(
                          child: Text(
                            'Map preview — ${state.markers.length} markers, '
                            '${state.path.pathPoints.length} waypoints',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Maps lat/lng inside a fixed bounding box to canvas coordinates and
/// draws a synthetic grid, the flight path, and markers.
class _MapPainter extends CustomPainter {
  final List<MapMarkerEntity> markers;
  final DronePathEntity path;

  _MapPainter({required this.markers, required this.path});

  // Bounding box around the mock data
  static const double _minLat = 33.3090;
  static const double _maxLat = 33.3200;
  static const double _minLng = 44.3590;
  static const double _maxLng = 44.3710;

  Offset _project(LatLng p, Size size) {
    final dx = (p.longitude - _minLng) / (_maxLng - _minLng) * size.width;
    // Latitude grows upward, canvas y grows downward.
    final dy =
        (1 - (p.latitude - _minLat) / (_maxLat - _minLat)) * size.height;
    return Offset(dx, dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bg = Paint()..color = AppColors.backgroundDeep;
    canvas.drawRect(Offset.zero & size, bg);

    // Grid
    final gridPaint = Paint()
      ..color = AppColors.borderDim
      ..strokeWidth = 0.5;
    const cells = 12;
    for (int i = 0; i <= cells; i++) {
      final x = size.width * i / cells;
      final y = size.height * i / cells;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Flight path
    if (path.pathPoints.length > 1) {
      final pathPaint = Paint()
        ..color = AppColors.neonGreen
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      final p = Path()
        ..moveTo(_project(path.pathPoints.first, size).dx,
            _project(path.pathPoints.first, size).dy);
      for (final pt in path.pathPoints.skip(1)) {
        final o = _project(pt, size);
        p.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(p, pathPaint);
    }

    // Detection markers
    for (final m in markers) {
      final c = _project(m.latLng, size);
      final color = switch (m.type) {
        MarkerType.fire => AppColors.alertFire,
        MarkerType.disease => AppColors.alertDisease,
        MarkerType.drone => AppColors.neonGreen,
        MarkerType.waypoint => AppColors.textSecondary,
      };
      canvas.drawCircle(
        c,
        14,
        Paint()..color = color.withOpacity(0.18),
      );
      canvas.drawCircle(c, 7, Paint()..color = color);
      canvas.drawCircle(
        c,
        7,
        Paint()
          ..color = AppColors.backgroundDeep
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Drone current position
    final drone = _project(path.currentPosition, size);
    canvas.drawCircle(
      drone,
      18,
      Paint()..color = AppColors.neonGreen.withOpacity(0.25),
    );
    canvas.drawCircle(
      drone,
      9,
      Paint()..color = AppColors.neonGreen,
    );
    canvas.drawCircle(
      drone,
      9,
      Paint()
        ..color = AppColors.backgroundDeep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) =>
      old.markers != markers || old.path != path;
}
