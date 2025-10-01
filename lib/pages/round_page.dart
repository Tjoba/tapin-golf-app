import 'package:flutter/material.dart';
import '../services/golf_course_service.dart';
import '../widgets/hybrid_golf_map.dart';

class RoundPage extends StatefulWidget {
  final String courseName;
  final List<String> selectedPlayers;

  const RoundPage({
    super.key,
    required this.courseName,
    required this.selectedPlayers,
  });

  @override
  State<RoundPage> createState() => _RoundPageState();
}

class _RoundPageState extends State<RoundPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  int currentHole = 1;
  bool _showSatelliteView = true;
  
  GolfCourseData? _courseData;
  bool _isLoadingCourseData = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _loadGolfCourseData();
  }

  Future<void> _loadGolfCourseData() async {
    try {
      setState(() {
        _isLoadingCourseData = true;
        _loadingError = null;
      });

      final courseData = await GolfCourseService.fetchGolfCourseData(widget.courseName);
      
      if (mounted) {
        setState(() {
          _courseData = courseData;
          _isLoadingCourseData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingError = e.toString();
          _isLoadingCourseData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getHoleInfo() {
    if (_courseData != null && currentHole <= _courseData!.holes.length) {
      final hole = _courseData!.holes[currentHole - 1];
      return 'Par ${hole.par} • ${hole.meters} meters';
    }
    return 'Par 4 • 385 yards';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: Colors.green[50]),
            child: _isLoadingCourseData 
                ? const Center(child: CircularProgressIndicator())
                : _loadingError != null
                    ? const Center(child: Icon(Icons.error))
                    : HybridGolfMap(
                        courseData: _courseData,
                        currentHole: currentHole,
                        showSatellite: _showSatelliteView,
                        onToggleView: () {
                          setState(() {
                            _showSatelliteView = !_showSatelliteView;
                          });
                        },
                      ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Hole $currentHole • ${_getHoleInfo()}',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Inter',
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.selectedPlayers.length} Players',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Hole navigation buttons
          Positioned(
            right: 16,
            top: 140,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_up,
                      size: 20,
                      color: currentHole < 18 ? Colors.green[700] : Colors.grey[400],
                    ),
                    onPressed: currentHole < 18 ? () {
                      setState(() {
                        currentHole++;
                      });
                    } : null,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: currentHole > 1 ? Colors.green[700] : Colors.grey[400],
                    ),
                    onPressed: currentHole > 1 ? () {
                      setState(() {
                        currentHole--;
                      });
                    } : null,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
