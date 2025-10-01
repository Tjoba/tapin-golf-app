import 'package:flutter/material.dart';
import '../services/golf_course_service.dart';
import 'dart:math' as math;

class GolfCourseMapPainter extends CustomPainter {
  final GolfCourseData? courseData;
  final int currentHole;
  final Size canvasSize;

  GolfCourseMapPainter({
    required this.courseData,
    required this.currentHole,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (courseData == null) {
      _paintLoadingPlaceholder(canvas, size);
      return;
    }

    // Get current hole data
    if (currentHole > courseData!.holes.length) {
      _paintHoleNotFound(canvas, size);
      return;
    }

    final currentHoleData = courseData!.holes[currentHole - 1];

    // Calculate bounds for current hole only
    final bounds = _calculateHoleBounds(currentHoleData, courseData!);
    final scale = _calculateScale(bounds, size);
    final offset = _calculateOffset(bounds, size, scale);

    // Draw course features only around current hole
    _drawHoleFeatures(canvas, courseData!, currentHoleData, scale, offset);

    // Draw current hole prominently
    _drawCurrentHole(canvas, currentHoleData, scale, offset);
  }

  void _paintLoadingPlaceholder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw loading indicator
    final center = Offset(size.width / 2, size.height / 2);
    final loadingPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, 30, loadingPaint);
  }

  void _paintHoleNotFound(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw error indicator
    final center = Offset(size.width / 2, size.height / 2);
    final errorPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, 40, errorPaint);
  }

  MapBounds _calculateHoleBounds(HoleData hole, GolfCourseData courseData) {
    // Create bounds around the specific hole with some padding
    final tee = hole.teePosition;
    final green = hole.greenPosition;
    
    // Calculate distance between tee and green
    final distance = _calculateDistance(tee, green);
    
    // Add padding based on hole length (minimum 100m, maximum 300m padding)
    final padding = math.max(0.001, math.min(0.003, distance * 0.3));
    
    double minLat = math.min(tee.latitude, green.latitude) - padding;
    double maxLat = math.max(tee.latitude, green.latitude) + padding;
    double minLng = math.min(tee.longitude, green.longitude) - padding;
    double maxLng = math.max(tee.longitude, green.longitude) + padding;

    // Include nearby features that might be relevant to this hole
    for (final feature in courseData.features) {
      for (final point in feature.points) {
        // Only include features within reasonable distance of the hole
        if (_isPointNearHole(point, hole, padding * 2)) {
          minLat = math.min(minLat, point.latitude);
          maxLat = math.max(maxLat, point.latitude);
          minLng = math.min(minLng, point.longitude);
          maxLng = math.max(maxLng, point.longitude);
        }
      }
    }

    return MapBounds(minLat, maxLat, minLng, maxLng);
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final double lat1Rad = point1.latitude * math.pi / 180;
    final double lat2Rad = point2.latitude * math.pi / 180;
    final double deltaLatRad = (point2.latitude - point1.latitude) * math.pi / 180;
    final double deltaLngRad = (point2.longitude - point1.longitude) * math.pi / 180;

    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  bool _isPointNearHole(LatLng point, HoleData hole, double threshold) {
    // Check if point is within threshold distance of either tee or green
    return (_calculateDistance(point, hole.teePosition) < threshold * 111000) ||
           (_calculateDistance(point, hole.greenPosition) < threshold * 111000);
  }

  void _drawHoleFeatures(Canvas canvas, GolfCourseData courseData, HoleData hole, double scale, Offset offset) {
    // Draw course outlines that are relevant to this hole
    for (final outline in courseData.courseOutlines) {
      if (outline.any((point) => _isPointNearHole(point, hole, 0.002))) {
        _drawOutline(canvas, outline, scale, offset);
      }
    }

    // Draw features relevant to this hole
    for (final feature in courseData.features) {
      if (feature.points.any((point) => _isPointNearHole(point, hole, 0.002))) {
        _drawFeature(canvas, feature, scale, offset);
      }
    }
  }

  void _drawOutline(Canvas canvas, List<LatLng> outline, double scale, Offset offset) {
    if (outline.length < 3) return;

    final paint = Paint()
      ..color = Colors.green.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    final firstPoint = _latLngToOffset(outline.first, scale, offset);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < outline.length; i++) {
      final point = _latLngToOffset(outline[i], scale, offset);
      path.lineTo(point.dx, point.dy);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawCurrentHole(Canvas canvas, HoleData hole, double scale, Offset offset) {
    final teePoint = _latLngToOffset(hole.teePosition, scale, offset);
    final greenPoint = _latLngToOffset(hole.greenPosition, scale, offset);

    // Draw connecting line with gradient or pattern
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final dashedLinePaint = Paint()
      ..color = Colors.green[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw background line
    canvas.drawLine(teePoint, greenPoint, linePaint);
    
    // Draw dashed line on top
    _drawDashedLine(canvas, teePoint, greenPoint, dashedLinePaint);

    // Draw tee box
    final teePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final teeStrokePaint = Paint()
      ..color = Colors.green[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(teePoint, 15, teePaint);
    canvas.drawCircle(teePoint, 15, teeStrokePaint);

    // Draw green
    final greenPaint = Paint()
      ..color = Colors.green[400]!
      ..style = PaintingStyle.fill;

    final greenStrokePaint = Paint()
      ..color = Colors.green[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(greenPoint, 20, greenPaint);
    canvas.drawCircle(greenPoint, 20, greenStrokePaint);

    // Draw flag on green
    _drawFlag(canvas, greenPoint);

    // Draw hole number on tee
    final textPainter = TextPainter(
      text: TextSpan(
        text: hole.number.toString(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        teePoint.dx - textPainter.width / 2,
        teePoint.dy - textPainter.height / 2,
      ),
    );

    // Draw distance indicator
    _drawDistanceIndicator(canvas, teePoint, greenPoint, hole);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashLength = 8;
    const double spaceLength = 4;
    
    final distance = (end - start).distance;
    final dashCount = (distance / (dashLength + spaceLength)).floor();
    
    final unitVector = (end - start) / distance;
    
    for (int i = 0; i < dashCount; i++) {
      final dashStart = start + unitVector * (i * (dashLength + spaceLength));
      final dashEnd = dashStart + unitVector * dashLength;
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  void _drawFlag(Canvas canvas, Offset greenCenter) {
    final flagPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final polePaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw flag pole
    canvas.drawLine(
      Offset(greenCenter.dx + 15, greenCenter.dy - 25),
      Offset(greenCenter.dx + 15, greenCenter.dy + 5),
      polePaint,
    );

    // Draw flag
    final flagPath = Path();
    flagPath.moveTo(greenCenter.dx + 15, greenCenter.dy - 25);
    flagPath.lineTo(greenCenter.dx + 35, greenCenter.dy - 15);
    flagPath.lineTo(greenCenter.dx + 15, greenCenter.dy - 5);
    flagPath.close();

    canvas.drawPath(flagPath, flagPaint);
  }

  void _drawDistanceIndicator(Canvas canvas, Offset tee, Offset green, HoleData hole) {
    final midPoint = Offset(
      (tee.dx + green.dx) / 2,
      (tee.dy + green.dy) / 2 - 30,
    );

    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.green[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw background for distance text
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: midPoint, width: 80, height: 25),
        const Radius.circular(12),
      ),
      backgroundPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: midPoint, width: 80, height: 25),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // Draw distance text
    final distanceText = TextPainter(
      text: TextSpan(
        text: '${hole.meters}m',
        style: TextStyle(
          color: Colors.green[800],
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    distanceText.layout();
    distanceText.paint(
      canvas,
      Offset(
        midPoint.dx - distanceText.width / 2,
        midPoint.dy - distanceText.height / 2,
      ),
    );
  }

  double _calculateScale(MapBounds bounds, Size size) {
    final latRange = bounds.maxLat - bounds.minLat;
    final lngRange = bounds.maxLng - bounds.minLng;
    
    final scaleX = size.width / lngRange;
    final scaleY = size.height / latRange;
    
    return math.min(scaleX, scaleY) * 0.8; // 80% to add padding for single hole view
  }

  Offset _calculateOffset(MapBounds bounds, Size size, double scale) {
    final latRange = bounds.maxLat - bounds.minLat;
    final lngRange = bounds.maxLng - bounds.minLng;
    
    final mapWidth = lngRange * scale;
    final mapHeight = latRange * scale;
    
    return Offset(
      (size.width - mapWidth) / 2 - bounds.minLng * scale,
      (size.height - mapHeight) / 2 + bounds.maxLat * scale,
    );
  }

  Offset _latLngToOffset(LatLng latLng, double scale, Offset offset) {
    return Offset(
      latLng.longitude * scale + offset.dx,
      -latLng.latitude * scale + offset.dy,
    );
  }

  void _drawFeature(Canvas canvas, GolfFeature feature, double scale, Offset offset) {
    Paint paint;
    
    switch (feature.type) {
      case GolfFeatureType.tee:
        paint = Paint()
          ..color = Colors.brown.withOpacity(0.6)
          ..style = PaintingStyle.fill;
        break;
      case GolfFeatureType.green:
        paint = Paint()
          ..color = Colors.green[400]!.withOpacity(0.7)
          ..style = PaintingStyle.fill;
        break;
      case GolfFeatureType.fairway:
        paint = Paint()
          ..color = Colors.green[300]!.withOpacity(0.5)
          ..style = PaintingStyle.fill;
        break;
      case GolfFeatureType.rough:
        paint = Paint()
          ..color = Colors.green[700]!.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        break;
      case GolfFeatureType.water:
        paint = Paint()
          ..color = Colors.blue.withOpacity(0.6)
          ..style = PaintingStyle.fill;
        break;
      case GolfFeatureType.bunker:
        paint = Paint()
          ..color = Colors.yellow[100]!.withOpacity(0.7)
          ..style = PaintingStyle.fill;
        break;
    }

    if (feature.points.length == 1) {
      // Point feature
      final point = _latLngToOffset(feature.points.first, scale, offset);
      canvas.drawCircle(point, 6, paint);
    } else if (feature.points.length >= 3) {
      // Polygon feature
      final path = Path();
      final firstPoint = _latLngToOffset(feature.points.first, scale, offset);
      path.moveTo(firstPoint.dx, firstPoint.dy);

      for (int i = 1; i < feature.points.length; i++) {
        final point = _latLngToOffset(feature.points[i], scale, offset);
        path.lineTo(point.dx, point.dy);
      }
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(GolfCourseMapPainter oldDelegate) {
    return oldDelegate.courseData != courseData || 
           oldDelegate.currentHole != currentHole ||
           oldDelegate.canvasSize != canvasSize;
  }
}

class MapBounds {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  MapBounds(this.minLat, this.maxLat, this.minLng, this.maxLng);
}