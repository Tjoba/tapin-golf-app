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
  bool _isBottomPanelExpanded = false; // Add this for panel state
  
  // Score tracking for each player
  Map<String, int> _playerScores = {};
  // Total relative score tracking (cumulative over/under par)
  Map<String, int> _playerTotalScores = {};
  
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
    
    // Initialize empty player scores - will be set after course data loads
    for (String player in widget.selectedPlayers) {
      _playerScores[player] = 0;
      _playerTotalScores[player] = 0; // Example: 0 initially, will be calculated
    }
    
    _loadGolfCourseData();
  }

  void _initializePlayerScores() {
    final courseData = _courseData;
    if (courseData != null && courseData.holes.isNotEmpty && currentHole <= courseData.holes.length) {
      int currentHolePar = courseData.holes[currentHole - 1].par;
      for (String player in widget.selectedPlayers) {
        // Set current hole score to par
        _playerScores[player] = currentHolePar;
        // Keep total scores as they are (don't reset to 0)
        if (_playerTotalScores[player] == null) {
          _playerTotalScores[player] = 0; // Only initialize if not set
        }
      }
    } else {
      // Fallback to par 4 if no course data
      for (String player in widget.selectedPlayers) {
        _playerScores[player] = 4;
        if (_playerTotalScores[player] == null) {
          _playerTotalScores[player] = 0;
        }
      }
    }
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
          // Initialize player scores with actual par data
          _initializePlayerScores();
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

  String _formatPlayerName(String fullName) {
    List<String> nameParts = fullName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0]} ${nameParts[1][0]}.';
    }
    return fullName;
  }

  void _updatePlayerScore(String playerName, int change) {
    setState(() {
      int currentScore = _playerScores[playerName] ?? 4;
      int newScore = currentScore + change;
      // Don't allow score to go below 1
      if (newScore >= 1) {
        _playerScores[playerName] = newScore;
      }
    });
  }

  String _getScoreDisplay(String playerName) {
    int score = _playerScores[playerName] ?? 4;
    return score.toString();
  }

  String _getTotalScoreDisplay(String playerName) {
    int totalScore = _playerTotalScores[playerName] ?? 0;
    if (totalScore == 0) return 'E';
    if (totalScore > 0) return '+$totalScore';
    return totalScore.toString();
  }

  String? _getPlayerImageUrl(String playerName) {
    // Map player names to their image URLs
    final playerImages = {
      'Tobias Hanner': 'https://media.licdn.com/dms/image/v2/C4D03AQGaqt95NNb4UQ/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1516782855402?e=1761782400&v=beta&t=S-xAJxOYW6H6jSkzSHMV85kwEUtztSZ5_2YjPq51TBY',
      'Martin Hanner': null, // No image available
    };
    return playerImages[playerName];
  }

  String _getHoleDistance() {
    final courseData = _courseData;
    if (courseData != null && 
        courseData.holes.isNotEmpty && 
        currentHole <= courseData.holes.length) {
      return '${courseData.holes[currentHole - 1].meters}m';
    }
    return '150m';
  }

  String _getHolePar() {
    final courseData = _courseData;
    if (courseData != null && 
        courseData.holes.isNotEmpty && 
        currentHole <= courseData.holes.length) {
      return '${courseData.holes[currentHole - 1].par}';
    }
    return '4';
  }

  String _getHoleHandicap() {
    final courseData = _courseData;
    if (courseData != null && 
        courseData.holes.isNotEmpty && 
        currentHole <= courseData.holes.length) {
      final handicap = courseData.holes[currentHole - 1].handicap;
      return '${handicap ?? 1}';
    }
    return '8';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          // Back button
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
                iconSize: 20,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          // Hole information squares (left side)
          Positioned(
            left: 0,
            top: 140,
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Distance square
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'DISTANCE',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getHoleDistance(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Hole Number square
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'HOLE',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$currentHole',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Par square
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'PAR',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getHolePar(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Handicap square
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'HCP',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getHoleHandicap(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                        ),
                      ],
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
                        _initializePlayerScores(); // Update scores for new hole
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
                        _initializePlayerScores(); // Update scores for new hole
                      });
                    } : null,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          // Bottom panel with player information
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isBottomPanelExpanded = !_isBottomPanelExpanded;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    // Player content
                    Container(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          // Column headers
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                // Column 1: Player label
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'PLAYER',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                // Column 2: Current hole score label
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      'CURRENT HOLE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                // Column 3: Total score label
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      'TOTAL',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Always show first player
                          if (widget.selectedPlayers.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: const BoxDecoration(),
                              child: Row(
                                children: [
                                  // Column 1: Profile image and name
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        ClipOval(
                                          child: _getPlayerImageUrl(widget.selectedPlayers[0]) != null
                                              ? Image.network(
                                                  _getPlayerImageUrl(widget.selectedPlayers[0])!,
                                                  width: 32,
                                                  height: 32,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return CircleAvatar(
                                                      radius: 16,
                                                      backgroundColor: Colors.green[300],
                                                      child: Text(
                                                        widget.selectedPlayers[0][0].toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor: Colors.green[300],
                                                  child: Text(
                                                    widget.selectedPlayers[0][0].toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _formatPlayerName(widget.selectedPlayers[0]),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Column 2: Current hole score with +/- buttons
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _updatePlayerScore(widget.selectedPlayers[0], -1),
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: Colors.red[100],
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Icon(
                                                Icons.remove,
                                                size: 18,
                                                color: Colors.red[700],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              _getScoreDisplay(widget.selectedPlayers[0]),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _updatePlayerScore(widget.selectedPlayers[0], 1),
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: Colors.blue[100],
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                size: 18,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Column 3: Total score
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getTotalScoreDisplay(widget.selectedPlayers[0]),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Show remaining players when expanded
                          if (_isBottomPanelExpanded && widget.selectedPlayers.length > 1)
                            ...widget.selectedPlayers.skip(1).map((player) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: const BoxDecoration(),
                                child: Row(
                                  children: [
                                    // Column 1: Profile image and name
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          ClipOval(
                                            child: _getPlayerImageUrl(player) != null
                                                ? Image.network(
                                                    _getPlayerImageUrl(player)!,
                                                    width: 32,
                                                    height: 32,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return CircleAvatar(
                                                        radius: 16,
                                                        backgroundColor: Colors.grey[400],
                                                        child: Text(
                                                          player[0].toUpperCase(),
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor: Colors.grey[400],
                                                    child: Text(
                                                      player[0].toUpperCase(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _formatPlayerName(player),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Column 2: Current hole score with +/- buttons
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: () => _updatePlayerScore(player, -1),
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: Colors.red[100],
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 16,
                                                  color: Colors.red[700],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.grey[300]!,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                _getScoreDisplay(player),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                  fontFamily: 'Inter',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () => _updatePlayerScore(player, 1),
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[100],
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 16,
                                                  color: Colors.blue[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Column 3: Total score
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _getTotalScoreDisplay(player),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
