import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'dart:math' as math;
import '../services/golf_course_service.dart';

class HybridGolfMap extends StatefulWidget {
  final GolfCourseData? courseData;
  final int currentHole;
  final bool showSatellite;
  final VoidCallback? onToggleView;

  const HybridGolfMap({
    super.key,
    required this.courseData,
    required this.currentHole,
    this.showSatellite = true,
    this.onToggleView,
  });

  @override
  State<HybridGolfMap> createState() => _HybridGolfMapState();
}

class _HybridGolfMapState extends State<HybridGolfMap> {
  late MapController _mapController;
  int? _lastHole;
  double _currentMapRotation = 0.0;
  
  // Store modified preferred path points for each hole
  Map<int, List<LatLng>> _modifiedPreferredPaths = {};
  
  // Track the last drag position for accurate placement
  latlong.LatLng? _lastDragPosition;
  Offset? _dragStartPosition;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Set initial rotation after a minimal delay to ensure map is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _centerOnCurrentHole();
      }
    });
  }

  @override
  void didUpdateWidget(HybridGolfMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update when hole actually changes
    if (oldWidget.currentHole != widget.currentHole) {
      _lastHole = widget.currentHole;
      // Use minimal delay to prevent rapid updates
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted && _lastHole == widget.currentHole) {
          _centerOnCurrentHole();
        }
      });
    }
  }

  void _centerOnCurrentHole() {
    if (widget.courseData == null || widget.currentHole > widget.courseData!.holes.length) {
      return;
    }

    try {
      final currentHoleData = widget.courseData!.holes[widget.currentHole - 1];
      
      // Calculate bearing from tee to green
      final teePos = currentHoleData.teePosition;
      final greenPos = currentHoleData.greenPosition;
      
      final dx = greenPos.longitude - teePos.longitude;
      final dy = greenPos.latitude - teePos.latitude;
      
      // Use atan2 to get angle from tee to green
      final bearingRadians = math.atan2(dx, dy);
      final bearingDegrees = bearingRadians * 180 / math.pi;
      
      // Calculate rotation needed to put green "up" (north)
      final targetRotation = -bearingDegrees;
      
      // Store the rotation for counter-rotating text and trigger rebuild
      setState(() {
        _currentMapRotation = targetRotation;
      });
      
      // Set rotation first (rotation is relative to center)
      _mapController.rotate(targetRotation);
      
      // Calculate screen-relative offset (in degrees)
      // We want tee at bottom, so offset center northward from tee
      final offsetDistance = 0.0025; // Adjust this to control tee position
      
      // Apply rotation to offset vector
      final offsetAngle = bearingRadians; // Direction from tee toward green
      final offsetX = math.sin(offsetAngle) * offsetDistance;
      final offsetY = math.cos(offsetAngle) * offsetDistance;
      
      // Calculate center position
      final center = latlong.LatLng(
        teePos.latitude + offsetY,
        teePos.longitude + offsetX,
      );
      
      // Move map to center position
      _mapController.move(center, 16.5);
    } catch (e) {
      // Silent fallback - don't crash the app
      print('Map centering failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.courseData == null) {
      return Container(
        color: Colors.green[50],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        _buildEmergencyMap(),
      ],
    );
  }

  Widget _buildEmergencyMap() {
    if (widget.courseData == null || widget.currentHole > widget.courseData!.holes.length) {
      return Container(color: Colors.green[50]);
    }

    final currentHoleData = widget.courseData!.holes[widget.currentHole - 1];
    
    // Calculate center point based on tee position with offset
    // Use tee position as reference and apply offset to put tee at bottom
    latlong.LatLng center;
    
    if (currentHoleData.preferredPath != null && currentHoleData.preferredPath!.isNotEmpty) {
      // Use the strategic path's midpoint as center reference
      final midIndex = currentHoleData.preferredPath!.length ~/ 2;
      center = latlong.LatLng(
        currentHoleData.preferredPath![midIndex].latitude,
        currentHoleData.preferredPath![midIndex].longitude,
      );
    } else {
      // Position map so tee is at the bottom and green direction varies
      final teePos = currentHoleData.teePosition;
      
      // Position the center so tee appears at bottom of screen
      // This is a rough approximation - zoom level affects this
      // Use the tee position as center and let the zoom level control positioning
      center = latlong.LatLng(
        teePos.latitude, 
        teePos.longitude,
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16.5, // Zoomed out a bit to show more area
        minZoom: 10.0,
        maxZoom: 20.0,
        backgroundColor: Colors.green[50]!,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        // Base satellite layer
        TileLayer(
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.example.app',
        ),
        // Path overlay
        PolylineLayer(
          polylines: _buildSimplePath(currentHoleData),
        ),
        // Markers overlay
        MarkerLayer(
          markers: _buildSimpleMarkers(currentHoleData),
        ),
      ],
    );
  }

  List<Polyline> _buildSimplePath(HoleData hole) {
    // Create simple path - either strategic or direct
    List<latlong.LatLng> pathPoints;
    
    final preferredPath = _getPreferredPath(hole);
    if (preferredPath != null && preferredPath.isNotEmpty) {
      pathPoints = preferredPath.map((point) => 
        latlong.LatLng(point.latitude, point.longitude)
      ).toList();
    } else {
      pathPoints = [
        latlong.LatLng(hole.teePosition.latitude, hole.teePosition.longitude),
        latlong.LatLng(hole.greenPosition.latitude, hole.greenPosition.longitude),
      ];
    }

    return [
      Polyline(
        points: pathPoints,
        color: Colors.white,
        strokeWidth: 3.0,
      ),
    ];
  }

  // Get the preferred path for a hole (either modified or original)
  List<LatLng>? _getPreferredPath(HoleData hole) {
    return _modifiedPreferredPaths[hole.number] ?? hole.preferredPath;
  }

  // Update a specific point in the preferred path
  void _updatePreferredPathPoint(HoleData hole, int pointIndex, latlong.LatLng newPosition) {
    setState(() {
      // Initialize the modified path if it doesn't exist
      if (_modifiedPreferredPaths[hole.number] == null) {
        _modifiedPreferredPaths[hole.number] = hole.preferredPath?.map((p) => LatLng(p.latitude, p.longitude)).toList() ?? [];
      }
      
      // Update the specific point
      if (pointIndex > 0 && pointIndex < _modifiedPreferredPaths[hole.number]!.length - 1) {
        _modifiedPreferredPaths[hole.number]![pointIndex] = LatLng(newPosition.latitude, newPosition.longitude);
      }
    });
  }

  // Handle marker drag update (during drag)
  void _handleMarkerDragUpdate(HoleData hole, int pointIndex, Offset globalPosition) {
    final point = _convertScreenToLatLng(globalPosition);
    if (point != null) {
      _lastDragPosition = point; // Store the last position
      _updatePreferredPathPoint(hole, pointIndex, point);
    }
  }

  // Handle marker drag end
  void _handleMarkerDrag(HoleData hole, int pointIndex, DraggableDetails details) {
    // Use the last drag position if available (most accurate)
    if (_lastDragPosition != null) {
      _updatePreferredPathPoint(hole, pointIndex, _lastDragPosition!);
    } else if (_dragStartPosition != null) {
      // Fallback: calculate final position from start + offset
      final finalPosition = _dragStartPosition! + details.offset;
      final point = _convertScreenToLatLng(finalPosition);
      if (point != null) {
        _updatePreferredPathPoint(hole, pointIndex, point);
      }
    }
    
    // Clear stored positions
    _lastDragPosition = null;
    _dragStartPosition = null;
  }

  // Convert screen coordinates to lat/lng
  latlong.LatLng? _convertScreenToLatLng(Offset globalPosition) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    // Convert global position to local position
    final localPosition = renderBox.globalToLocal(globalPosition);
    
    // Use the map controller's camera to convert screen coordinates to lat/lng
    final camera = _mapController.camera;
    
    // Convert screen point to lat/lng using the map's projection
    final point = camera.pointToLatLng(
      math.Point(localPosition.dx, localPosition.dy),
    );
    
    return point;
  }

  List<Marker> _buildSimpleMarkers(HoleData hole) {
    List<Marker> markers = [];
    
    // Tee marker - simple white circle
    markers.add(Marker(
      point: latlong.LatLng(hole.teePosition.latitude, hole.teePosition.longitude),
      width: 14,
      height: 14,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    ));
    
    // Add draggable white circles for preferred landing areas (fairway pins)
    final preferredPath = _getPreferredPath(hole);
    if (preferredPath != null && preferredPath.length > 2) {
      // Skip first (tee) and last (green) points, add white circles for intermediate points
      for (int i = 1; i < preferredPath.length - 1; i++) {
        final point = preferredPath[i];
        
        // Add draggable fairway marker (no distance label)
        markers.add(Marker(
          point: latlong.LatLng(point.latitude, point.longitude),
          width: 32,
          height: 32,
          child: Draggable<int>(
            data: i,
            feedback: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            childWhenDragging: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 2),
              ),
            ),
            onDragStarted: () {
              // Store the starting position of the marker
              final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final markerScreenPos = _mapController.camera.latLngToScreenPoint(
                  latlong.LatLng(point.latitude, point.longitude),
                );
                _dragStartPosition = Offset(markerScreenPos.x.toDouble(), markerScreenPos.y.toDouble());
              }
            },
            onDragUpdate: (details) {
              // Track position during drag for better feedback
              _handleMarkerDragUpdate(hole, i, details.globalPosition);
            },
            onDragEnd: (details) {
              _handleMarkerDrag(hole, i, details);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ));
        
        // Add distance markers between segments
        
        // Distance marker 1: Between tee and current fairway point
        final prevPoint = i == 1 ? hole.teePosition : preferredPath[i - 1];
        final distance1 = _calculateDistance(
          prevPoint.latitude, prevPoint.longitude,
          point.latitude, point.longitude,
        );
        
        // Calculate midpoint between previous point and current fairway point
        final midLat1 = (prevPoint.latitude + point.latitude) / 2;
        final midLng1 = (prevPoint.longitude + point.longitude) / 2;
        
        markers.add(Marker(
          point: latlong.LatLng(midLat1, midLng1),
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Transform.rotate(
                angle: -_currentMapRotation * math.pi / 180,
                child: Text(
                  '${distance1.round()}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
        ));
        
        // Distance marker 2: Between current fairway point and next point (or green if last)
        final nextPoint = i == preferredPath.length - 2 ? hole.greenPosition : preferredPath[i + 1];
        final distance2 = _calculateDistance(
          point.latitude, point.longitude,
          nextPoint.latitude, nextPoint.longitude,
        );
        
        // Calculate midpoint between current fairway point and next point
        final midLat2 = (point.latitude + nextPoint.latitude) / 2;
        final midLng2 = (point.longitude + nextPoint.longitude) / 2;
        
        markers.add(Marker(
          point: latlong.LatLng(midLat2, midLng2),
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Transform.rotate(
                angle: -_currentMapRotation * math.pi / 180,
                child: Text(
                  '${distance2.round()}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
        ));
      }
    }

    // Green marker - white dot with transparent space and white circle around it
    markers.add(Marker(
      point: latlong.LatLng(hole.greenPosition.latitude, hole.greenPosition.longitude),
      width: 24,
      height: 24,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    ));
    
    return markers;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = (lat2 - lat1) * math.pi / 180;
    final double dLon = (lon2 - lon1) * math.pi / 180;
    
    final double a = math.sin(dLat/2) * math.sin(dLat/2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
        math.sin(dLon/2) * math.sin(dLon/2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
    
    return earthRadius * c * 1000; // Convert to meters
  }

}