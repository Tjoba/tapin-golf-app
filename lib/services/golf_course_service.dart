import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class GolfCourseService {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  
  // Sample golf course coordinates (can be expanded with real data)
  static const Map<String, Map<String, double>> _courseCoordinates = {
    'Pebble Beach Golf Links': {
      'lat': 36.5681,
      'lng': -121.9465,
    },
    'TPC Sawgrass': {
      'lat': 30.1987,
      'lng': -81.3958,
    },
    'Presidio Golf Course': {
      'lat': 37.7976,
      'lng': -122.4683,
    },
    'Lincoln Park Golf Course': {
      'lat': 37.7835,
      'lng': -122.4949,
    },
    'Chambers Bay Golf Course': {
      'lat': 47.2009,
      'lng': -122.5662,
    },
    'Stockholms Golfklubb': {
      'lat': 59.3966,
      'lng': 18.0252,
    },
  };

  static Future<GolfCourseData?> fetchGolfCourseData(String courseName) async {
    final coordinates = _courseCoordinates[courseName];
    if (coordinates == null) {
      throw Exception('Course coordinates not found for: $courseName');
    }

    final lat = coordinates['lat']!;
    final lng = coordinates['lng']!;
    
    // Create bounding box around the golf course (approximately 1km radius)
    final bbox = _createBoundingBox(lat, lng, 1000);
    
    final query = '''
[out:json][timeout:25];
(
  way["leisure"="golf_course"](${bbox['south']},${bbox['west']},${bbox['north']},${bbox['east']});
  way["golf"~"."](${bbox['south']},${bbox['west']},${bbox['north']},${bbox['east']});
  way["sport"="golf"](${bbox['south']},${bbox['west']},${bbox['north']},${bbox['east']});
  relation["leisure"="golf_course"](${bbox['south']},${bbox['west']},${bbox['north']},${bbox['east']});
  relation["golf"~"."](${bbox['south']},${bbox['west']},${bbox['north']},${bbox['east']});
);
out geom;
''';

    try {
      final response = await http.post(
        Uri.parse(_overpassUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'data=$query',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseGolfCourseData(data, courseName, lat, lng);
      } else {
        throw Exception('Failed to fetch golf course data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching golf course data: $e');
    }
  }

  static Map<String, double> _createBoundingBox(double lat, double lng, double radiusMeters) {
    // Convert radius from meters to degrees (approximate)
    final latDelta = radiusMeters / 111000; // 1 degree lat ≈ 111km
    final lngDelta = radiusMeters / (111000 * math.cos(lat * math.pi / 180));
    
    return {
      'north': lat + latDelta,
      'south': lat - latDelta,
      'east': lng + lngDelta,
      'west': lng - lngDelta,
    };
  }

  static GolfCourseData _parseGolfCourseData(Map<String, dynamic> data, String courseName, double centerLat, double centerLng) {
    final elements = data['elements'] as List<dynamic>? ?? [];
    
    List<GolfFeature> features = [];
    List<List<LatLng>> courseOutlines = [];
    List<HoleData> holes = [];

    for (final element in elements) {
      final tags = element['tags'] as Map<String, dynamic>? ?? {};
      final geometry = element['geometry'] as List<dynamic>? ?? [];
      
      if (geometry.isEmpty) continue;
      
      final points = geometry.map((point) => LatLng(
        point['lat']?.toDouble() ?? 0.0,
        point['lon']?.toDouble() ?? 0.0,
      )).toList();

      // Parse different golf course features
      if (tags['leisure'] == 'golf_course' || tags['sport'] == 'golf') {
        courseOutlines.add(points);
      } else if (tags['golf'] == 'tee') {
        features.add(GolfFeature(
          type: GolfFeatureType.tee,
          points: points,
          name: tags['name'] ?? 'Tee',
          holeNumber: _parseHoleNumber(tags),
        ));
      } else if (tags['golf'] == 'green') {
        features.add(GolfFeature(
          type: GolfFeatureType.green,
          points: points,
          name: tags['name'] ?? 'Green',
          holeNumber: _parseHoleNumber(tags),
        ));
      } else if (tags['golf'] == 'fairway') {
        features.add(GolfFeature(
          type: GolfFeatureType.fairway,
          points: points,
          name: tags['name'] ?? 'Fairway',
          holeNumber: _parseHoleNumber(tags),
        ));
      } else if (tags['golf'] == 'rough') {
        features.add(GolfFeature(
          type: GolfFeatureType.rough,
          points: points,
          name: tags['name'] ?? 'Rough',
          holeNumber: _parseHoleNumber(tags),
        ));
      } else if (tags['golf'] == 'bunker' || tags['natural'] == 'sand') {
        features.add(GolfFeature(
          type: GolfFeatureType.bunker,
          points: points,
          name: tags['name'] ?? 'Bunker',
        ));
      } else if (tags['natural'] == 'water' || tags['leisure'] == 'water_park') {
        features.add(GolfFeature(
          type: GolfFeatureType.water,
          points: points,
          name: tags['name'] ?? 'Water Hazard',
        ));
      } else if (tags['golf'] == 'hole') {
        // Parse complete hole data with strategic path geometry
        final holeNumber = _parseHoleNumber(tags) ?? 1;
        final par = int.tryParse(tags['par'] ?? '4') ?? 4;
        final handicap = int.tryParse(tags['handicap'] ?? '10');
        final holeName = tags['name'] ?? 'Hole $holeNumber';
        
        if (points.length >= 2) {
          // OpenStreetMap hole geometry represents the strategic path
          // First point is typically the tee, last point is typically the green
          final teePosition = points.first;
          final greenPosition = points.last;
          final distance = _calculateDistance(teePosition, greenPosition);
          
          holes.add(HoleData(
            number: holeNumber,
            par: par,
            meters: distance.round(),
            teePosition: teePosition,
            greenPosition: greenPosition,
            preferredPath: points, // Use the actual OpenStreetMap hole geometry as strategic path
            holeName: holeName,
            handicap: handicap,
          ));
        }
      }
    }

    // Generate hole data from actual tees and greens found, or use sample data
    if (holes.isEmpty) {
      holes = _generateHolesFromFeatures(features, centerLat, centerLng);
    }

    return GolfCourseData(
      name: courseName,
      centerLat: centerLat,
      centerLng: centerLng,
      features: features,
      courseOutlines: courseOutlines,
      holes: holes,
    );
  }

  static List<HoleData> _generateHolesFromFeatures(List<GolfFeature> features, double centerLat, double centerLng) {
    // Extract tees, greens, and fairways from the parsed features
    final tees = features.where((f) => f.type == GolfFeatureType.tee).toList();
    final greens = features.where((f) => f.type == GolfFeatureType.green).toList();
    final fairways = features.where((f) => f.type == GolfFeatureType.fairway).toList();
    
    List<HoleData> holes = [];
    
    // If we have actual tees and greens from the API, try to pair them up intelligently
    if (tees.isNotEmpty && greens.isNotEmpty) {
      final pars = [4, 3, 5, 4, 4, 3, 4, 5, 4, 4, 3, 4, 5, 4, 3, 4, 4, 5];
      
      // First, try to match by hole number if available
      Map<int, GolfFeature> teesByHole = {};
      Map<int, GolfFeature> greensByHole = {};
      Map<int, GolfFeature> fairwaysByHole = {};
      
      for (final tee in tees) {
        if (tee.holeNumber != null) {
          teesByHole[tee.holeNumber!] = tee;
        }
      }
      
      for (final green in greens) {
        if (green.holeNumber != null) {
          greensByHole[green.holeNumber!] = green;
        }
      }
      
      for (final fairway in fairways) {
        if (fairway.holeNumber != null) {
          fairwaysByHole[fairway.holeNumber!] = fairway;
        }
      }
      
      // Create holes from numbered matches
      for (int holeNum = 1; holeNum <= 18; holeNum++) {
        if (teesByHole.containsKey(holeNum) && greensByHole.containsKey(holeNum)) {
          final teeCenter = _getFeatureCenter(teesByHole[holeNum]!);
          final greenCenter = _getFeatureCenter(greensByHole[holeNum]!);
          final greenFeature = greensByHole[holeNum]!;
          final distance = _calculateDistance(teeCenter, greenCenter);
          final meters = distance.round(); // Keep as meters
          final par = holeNum <= pars.length ? pars[holeNum - 1] : 4;
          
          // Calculate green distances using green geometry
          final greenDistances = _calculateGreenDistances(teeCenter, greenFeature.points);
          
          // Use actual fairway geometry if available for this hole
          List<LatLng>? preferredPath;
          if (fairwaysByHole.containsKey(holeNum)) {
            preferredPath = _extractFairwayPath(fairwaysByHole[holeNum]!, teeCenter, greenCenter);
          } else {
            // Fall back to generated strategic path
            preferredPath = _generateStrategicPath(teeCenter, greenCenter, par, meters > 0 ? meters : 400);
          }
          
          holes.add(HoleData(
            number: holeNum,
            par: par,
            meters: meters > 0 ? meters : 400,
            teePosition: teeCenter,
            greenPosition: greenCenter,
            preferredPath: preferredPath,
            frontGreenDistance: greenDistances['front'],
            backGreenDistance: greenDistances['back'],
            greenGeometry: greenFeature.points,
          ));
        }
      }
      
      // If we don't have enough numbered holes, use proximity matching for remaining tees/greens
      if (holes.length < math.min(tees.length, greens.length)) {
        final usedTees = teesByHole.values.toSet();
        final usedGreens = greensByHole.values.toSet();
        final remainingTees = tees.where((t) => !usedTees.contains(t)).toList();
        final remainingGreens = greens.where((g) => !usedGreens.contains(g)).toList();
        
        // Sort tees by distance from course center (assuming holes start near clubhouse)
        remainingTees.sort((a, b) {
          final distA = _calculateDistance(_getFeatureCenter(a), LatLng(centerLat, centerLng));
          final distB = _calculateDistance(_getFeatureCenter(b), LatLng(centerLat, centerLng));
          return distA.compareTo(distB);
        });
        
        // For each remaining tee, find the closest green
        for (int i = 0; i < remainingTees.length && remainingGreens.isNotEmpty; i++) {
          final tee = remainingTees[i];
          final teeCenter = _getFeatureCenter(tee);
          
          // Find closest available green
          GolfFeature? closestGreen;
          double minDistance = double.infinity;
          
          for (final green in remainingGreens) {
            final greenCenter = _getFeatureCenter(green);
            final distance = _calculateDistance(teeCenter, greenCenter);
            if (distance < minDistance) {
              minDistance = distance;
              closestGreen = green;
            }
          }
          
          if (closestGreen != null) {
            final greenCenter = _getFeatureCenter(closestGreen);
            final meters = minDistance.round(); // Keep as meters
            final holeNumber = holes.length + 1;
            final par = holeNumber <= pars.length ? pars[holeNumber - 1] : 4;
            
            // Calculate green distances using green geometry
            final greenDistances = _calculateGreenDistances(teeCenter, closestGreen.points);
            
            // Try to find a fairway that connects this tee and green
            List<LatLng>? preferredPath;
            GolfFeature? bestFairway;
            double bestFairwayScore = double.infinity;
            
            for (final fairway in fairways) {
              // Score fairway based on proximity to tee and green
              final fairwayCenter = _getFeatureCenter(fairway);
              final teeToFairway = _calculateDistance(teeCenter, fairwayCenter);
              final fairwayToGreen = _calculateDistance(fairwayCenter, greenCenter);
              final score = teeToFairway + fairwayToGreen;
              
              if (score < bestFairwayScore && score < minDistance * 1.5) { // Fairway should be reasonably close
                bestFairwayScore = score;
                bestFairway = fairway;
              }
            }
            
            if (bestFairway != null) {
              preferredPath = _extractFairwayPath(bestFairway, teeCenter, greenCenter);
            } else {
              preferredPath = _generateStrategicPath(teeCenter, greenCenter, par, meters > 0 ? meters : 400);
            }
            
            holes.add(HoleData(
              number: holeNumber,
              par: par,
              meters: meters > 0 ? meters : 400,
              teePosition: teeCenter,
              greenPosition: greenCenter,
              preferredPath: preferredPath,
              frontGreenDistance: greenDistances['front'],
              backGreenDistance: greenDistances['back'],
              greenGeometry: closestGreen.points,
            ));
            
            remainingGreens.remove(closestGreen);
          }
        }
      }
    }
    
    // If we don't have enough real data, fill with sample holes
    if (holes.length < 18) {
      final remainingHoles = _generateSampleHoles(centerLat, centerLng, holes.length);
      holes.addAll(remainingHoles);
    }
    
    // Sort holes by number and limit to 18
    holes.sort((a, b) => a.number.compareTo(b.number));
    return holes.take(18).toList();
  }
  
  static LatLng _getFeatureCenter(GolfFeature feature) {
    if (feature.points.isEmpty) {
      return LatLng(0, 0);
    }
    
    // Calculate the center point of the feature
    double totalLat = 0;
    double totalLng = 0;
    
    for (final point in feature.points) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }
    
    return LatLng(
      totalLat / feature.points.length,
      totalLng / feature.points.length,
    );
  }
  
  static List<LatLng> _extractFairwayPath(GolfFeature fairway, LatLng teePosition, LatLng greenPosition) {
    if (fairway.points.isEmpty) {
      // Fall back to generated path if no fairway geometry
      return [teePosition, greenPosition];
    }
    
    List<LatLng> path = [teePosition];
    
    // Find the fairway points that create the best strategic path
    // Sort fairway points by distance from tee to create a natural progression
    List<LatLng> fairwayPoints = List.from(fairway.points);
    fairwayPoints.sort((a, b) {
      final distA = _calculateDistance(teePosition, a);
      final distB = _calculateDistance(teePosition, b);
      return distA.compareTo(distB);
    });
    
    // Select strategic waypoints along the fairway
    // Take every 3rd-5th point to avoid too many waypoints while maintaining shape
    int step = math.max(1, fairwayPoints.length ~/ 4); // Divide into ~4 segments
    for (int i = step; i < fairwayPoints.length; i += step) {
      path.add(fairwayPoints[i]);
    }
    
    // Always end at the green
    path.add(greenPosition);
    
    return path;
  }

  static List<LatLng> _generateStrategicPath(LatLng teePosition, LatLng greenPosition, int par, int meters) {
    List<LatLng> path = [teePosition];
    
    // Generate intermediate waypoints based on hole characteristics
    if (par == 3) {
      // Par 3: Direct shot to green, but may have slight arc to avoid hazards
      if (meters > 150) {
        // Add slight curve for longer par 3s
        final midLat = (teePosition.latitude + greenPosition.latitude) / 2;
        final midLng = (teePosition.longitude + greenPosition.longitude) / 2;
        // Add small offset for strategic routing
        final offset = (meters > 180) ? 0.0001 : 0.00005;
        path.add(LatLng(midLat + offset, midLng));
      }
    } else if (par == 4) {
      // Par 4: Tee shot landing area, then approach to green
      final driveLat = teePosition.latitude + (greenPosition.latitude - teePosition.latitude) * 0.6;
      final driveLng = teePosition.longitude + (greenPosition.longitude - teePosition.longitude) * 0.6;
      
      // Add strategic landing area (optimal drive distance ~250m from tee)
      path.add(LatLng(driveLat, driveLng));
      
      // For doglegs, add curve
      if (meters > 350) {
        final approachLat = teePosition.latitude + (greenPosition.latitude - teePosition.latitude) * 0.85;
        final approachLng = teePosition.longitude + (greenPosition.longitude - teePosition.longitude) * 0.85;
        path.add(LatLng(approachLat, approachLng));
      }
    } else if (par == 5) {
      // Par 5: Tee shot, layup area, approach to green
      // First landing area (drive)
      final driveLat = teePosition.latitude + (greenPosition.latitude - teePosition.latitude) * 0.4;
      final driveLng = teePosition.longitude + (greenPosition.longitude - teePosition.longitude) * 0.4;
      path.add(LatLng(driveLat, driveLng));
      
      // Second landing area (layup or go for it)
      final layupLat = teePosition.latitude + (greenPosition.latitude - teePosition.latitude) * 0.75;
      final layupLng = teePosition.longitude + (greenPosition.longitude - teePosition.longitude) * 0.75;
      path.add(LatLng(layupLat, layupLng));
    }
    
    path.add(greenPosition);
    return path;
  }

  static double _calculateDistance(LatLng point1, LatLng point2) {
    // Calculate distance between two points using Haversine formula (returns meters)
    const double earthRadius = 6371000; // Earth radius in meters
    
    final lat1Rad = point1.latitude * math.pi / 180;
    final lat2Rad = point2.latitude * math.pi / 180;
    final deltaLatRad = (point2.latitude - point1.latitude) * math.pi / 180;
    final deltaLngRad = (point2.longitude - point1.longitude) * math.pi / 180;
    
    final a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  // Calculate front, center, and back distances to green
  static Map<String, int> _calculateGreenDistances(LatLng teePosition, List<LatLng> greenGeometry) {
    if (greenGeometry.isEmpty) {
      // Fallback if no green geometry available
      return {'front': 0, 'center': 0, 'back': 0};
    }

    // Calculate distances to all green edge points
    List<double> distances = greenGeometry
        .map((point) => _calculateDistance(teePosition, point))
        .toList();

    if (distances.isEmpty) {
      return {'front': 0, 'center': 0, 'back': 0};
    }

    // Front = closest point, Back = farthest point
    double frontDistance = distances.reduce(math.min);
    double backDistance = distances.reduce(math.max);
    
    // Center = average of all edge points (more accurate than single center point)
    double centerDistance = distances.reduce((a, b) => a + b) / distances.length;

    return {
      'front': frontDistance.round(),
      'center': centerDistance.round(), 
      'back': backDistance.round(),
    };
  }
  
  static int? _parseHoleNumber(Map<String, dynamic> tags) {
    // Try to extract hole number from various possible tag formats
    if (tags['hole'] != null) {
      return int.tryParse(tags['hole'].toString());
    }
    if (tags['ref'] != null) {
      return int.tryParse(tags['ref'].toString());
    }
    if (tags['name'] != null) {
      final name = tags['name'].toString().toLowerCase();
      // Look for patterns like "Hole 1", "1st hole", "Green 1", "Tee 1", etc.
      final match = RegExp(r'(\d+)').firstMatch(name);
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }
    }
    return null;
  }

  static List<HoleData> _generateSampleHoles(double centerLat, double centerLng, [int startIndex = 0]) {
    // Generate remaining holes with realistic data
    final totalHoles = 18 - startIndex;
    if (totalHoles <= 0) return [];
    
    return List.generate(totalHoles, (index) {
      final holeNumber = startIndex + index + 1;
      final pars = [4, 3, 5, 4, 4, 3, 4, 5, 4, 4, 3, 4, 5, 4, 3, 4, 4, 5]; // Typical golf course pars
      final meters = [350, 150, 475, 375, 345, 165, 390, 500, 360, 365, 155, 395, 465, 355, 140, 385, 330, 525]; // Converted from yards to meters
      
      final parIndex = (startIndex + index) % pars.length;
      final par = pars[parIndex];
      final holeMeters = meters[parIndex];
      
      // Sample tee and green positions relative to center
      final teePosition = LatLng(
        centerLat + ((startIndex + index) * 0.001) - 0.009,
        centerLng + (((startIndex + index) % 3) * 0.001) - 0.001,
      );
      final greenPosition = LatLng(
        centerLat + ((startIndex + index) * 0.001) - 0.005,
        centerLng + (((startIndex + index) % 3) * 0.001) + 0.002,
      );
      
      return HoleData(
        number: holeNumber,
        par: par,
        meters: holeMeters,
        teePosition: teePosition,
        greenPosition: greenPosition,
        preferredPath: _generateStrategicPath(teePosition, greenPosition, par, holeMeters),
        frontGreenDistance: holeMeters - 10, // Approximate front green distance
        backGreenDistance: holeMeters + 10, // Approximate back green distance
        greenGeometry: null, // No geometry available for sample holes
      );
    });
  }
}

// Data models
class GolfCourseData {
  final String name;
  final double centerLat;
  final double centerLng;
  final List<GolfFeature> features;
  final List<List<LatLng>> courseOutlines;
  final List<HoleData> holes;

  GolfCourseData({
    required this.name,
    required this.centerLat,
    required this.centerLng,
    required this.features,
    required this.courseOutlines,
    required this.holes,
  });
}

class GolfFeature {
  final GolfFeatureType type;
  final List<LatLng> points;
  final String name;
  final int? holeNumber;

  GolfFeature({
    required this.type,
    required this.points,
    required this.name,
    this.holeNumber,
  });
}

enum GolfFeatureType {
  tee,
  green,
  fairway,
  rough,
  water,
  bunker,
}

class HoleData {
  final int number;
  final int par;
  final int meters;
  final LatLng teePosition;
  final LatLng greenPosition;
  final List<LatLng>? preferredPath; // Strategic path from tee to green
  final String? holeName; // Name of the hole (e.g., "Tallbacken", "Kevinge")
  final int? handicap; // Hole difficulty ranking (1-18)
  final int? frontGreenDistance; // Distance to front of green
  final int? backGreenDistance; // Distance to back of green
  final List<LatLng>? greenGeometry; // Full green outline for calculations

  HoleData({
    required this.number,
    required this.par,
    required this.meters,
    required this.teePosition,
    required this.greenPosition,
    this.preferredPath,
    this.holeName,
    this.handicap,
    this.frontGreenDistance,
    this.backGreenDistance,
    this.greenGeometry,
  });
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
  
  @override
  String toString() => 'LatLng($latitude, $longitude)';
}