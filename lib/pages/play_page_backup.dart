import 'package:flutter/material.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  String selectedFilter = 'Booked'; // Default selected filter
  String? selectedCourse; // Track selected course

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60), // More safe area spacing
            // Header
            const Text(
              'Select golf course',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            // Search Bar
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TextField(
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search golf courses or locations...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Inter',
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  suffixIcon: Icon(
                    Icons.my_location,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Course Filter Menu
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CourseFilterChip(
                    label: 'Booked',
                    icon: Icons.calendar_today,
                    isSelected: selectedFilter == 'Booked',
                    onTap: () => setState(() => selectedFilter = 'Booked'),
                  ),
                  const SizedBox(width: 12),
                  _CourseFilterChip(
                    label: 'Closest',
                    icon: Icons.near_me,
                    isSelected: selectedFilter == 'Closest',
                    onTap: () => setState(() => selectedFilter = 'Closest'),
                  ),
                  const SizedBox(width: 12),
                  _CourseFilterChip(
                    label: 'Latest',
                    icon: Icons.access_time,
                    isSelected: selectedFilter == 'Latest',
                    onTap: () => setState(() => selectedFilter = 'Latest'),
                  ),
                  const SizedBox(width: 12),
                  _CourseFilterChip(
                    label: 'Favorites',
                    icon: Icons.favorite,
                    isSelected: selectedFilter == 'Favorites',
                    onTap: () => setState(() => selectedFilter = 'Favorites'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Course List based on selected filter
            _CourseListView(
              selectedFilter: selectedFilter,
              selectedCourse: selectedCourse,
              onCourseSelected: (courseName) {
                setState(() {
                  selectedCourse = selectedCourse == courseName ? null : courseName;
                });
              },
            ),
            const SizedBox(height: 30),
            // Player Selection Section
            const Text(
              'Select players',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),
            _PlayerSelectionWidget(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CourseListView extends StatelessWidget {
  final String selectedFilter;
  final String? selectedCourse;
  final Function(String) onCourseSelected;
  
  const _CourseListView({
    required this.selectedFilter,
    required this.selectedCourse,
    required this.onCourseSelected,
  });

  // Different course data based on selected filter
  List<Map<String, dynamic>> get _courses {
    switch (selectedFilter) {
      case 'Booked':
        return [
          {
            'courseName': 'Pebble Beach Golf Links',
            'location': 'Pebble Beach, CA',
            'distance': '2.3 miles',
            'rating': '4.8',
            'price': 'Booked',
            'imageUrl': 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=400&h=250&fit=crop',
          },
          {
            'courseName': 'TPC Sawgrass',
            'location': 'Ponte Vedra Beach, FL',
            'distance': '12.4 miles',
            'rating': '4.9',
            'price': 'Booked',
            'imageUrl': 'https://images.unsplash.com/photo-1593111774240-d529f12cf4bb?w=400&h=250&fit=crop',
          },
        ];
      case 'Closest':
        return [
          {
            'courseName': 'Presidio Golf Course',
            'location': 'San Francisco, CA',
            'distance': '0.8 miles',
            'rating': '4.3',
            'price': '\$85',
            'imageUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=250&fit=crop',
          },
          {
            'courseName': 'Lincoln Park Golf',
            'location': 'San Francisco, CA',
            'distance': '1.2 miles',
            'rating': '4.1',
            'price': '\$65',
            'imageUrl': 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=400&h=250&fit=crop',
          },
          {
            'courseName': 'Golden Gate Park Golf',
            'location': 'San Francisco, CA',
            'distance': '1.5 miles',
            'rating': '4.0',
            'price': '\$55',
            'imageUrl': 'https://images.unsplash.com/photo-1593111774240-d529f12cf4bb?w=400&h=250&fit=crop',
          },
        ];
      case 'Latest':
        return [
          {
            'courseName': 'Bandon Dunes Golf Resort',
            'location': 'Bandon, OR',
            'distance': '8.7 miles',
            'rating': '4.9',
            'price': '\$395',
            'imageUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=250&fit=crop',
          },
          {
            'courseName': 'Chambers Bay Golf Course',
            'location': 'University Place, WA',
            'distance': '15.3 miles',
            'rating': '4.7',
            'price': '\$275',
            'imageUrl': 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=400&h=250&fit=crop',
          },
          {
            'courseName': 'Streamsong Resort',
            'location': 'Bowling Green, FL',
            'distance': '22.1 miles',
            'rating': '4.8',
            'price': '\$325',
            'imageUrl': 'https://images.unsplash.com/photo-1593111774240-d529f12cf4bb?w=400&h=250&fit=crop',
          },
        ];
      case 'Favorites':
        return [
          {
            'courseName': 'Augusta National Golf Club',
            'location': 'Augusta, GA',
            'distance': '15.7 miles',
            'rating': '4.9',
            'price': '\$450',
            'imageUrl': 'https://images.unsplash.com/photo-1593111774240-d529f12cf4bb?w=400&h=250&fit=crop',
          },
          {
            'courseName': 'St. Andrews Old Course',
            'location': 'St. Andrews, Scotland',
            'distance': '2.1 miles',
            'rating': '4.8',
            'price': '\$320',
            'imageUrl': 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=400&h=250&fit=crop',
          },
          {
            'courseName': 'Cypress Point Club',
            'location': 'Pebble Beach, CA',
            'distance': '3.2 miles',
            'rating': '5.0',
            'price': 'Private',
            'imageUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=250&fit=crop',
          },
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Fixed height matching upcoming rounds
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          final isSelected = selectedCourse == course['courseName'];
          return GestureDetector(
            onTap: () => onCourseSelected(course['courseName']),
            child: Container(
              margin: EdgeInsets.only(
                right: index == _courses.length - 1 ? 0 : 16,
              ),
              width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: isSelected ? Border.all(
                  color: Colors.blue,
                  width: 3,
                ) : null,
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                    spreadRadius: isSelected ? 3 : 2,
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Course Image
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(course['imageUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Gradient Overlay
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Selection indicator
                    if (isSelected)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    // Course Info
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['courseName'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  course['location'],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                course['distance'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      course['rating'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  course['price'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CourseFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CourseFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerSelectionWidget extends StatefulWidget {
  @override
  State<_PlayerSelectionWidget> createState() => _PlayerSelectionWidgetState();
}

class _PlayerSelectionWidgetState extends State<_PlayerSelectionWidget> {
  final List<Map<String, dynamic>> _availablePlayers = [
    {'name': 'John Smith', 'handicap': '12', 'avatar': '👤', 'isSelected': true},
    {'name': 'Sarah Johnson', 'handicap': '8', 'avatar': '👩', 'isSelected': false},
    {'name': 'Mike Wilson', 'handicap': '15', 'avatar': '👨', 'isSelected': false},
    {'name': 'Emily Davis', 'handicap': '6', 'avatar': '👩‍💼', 'isSelected': false},
    {'name': 'Tom Brown', 'handicap': '18', 'avatar': '👨‍💼', 'isSelected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected players count
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.group,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${_availablePlayers.where((p) => p['isSelected']).length} player(s) selected',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Available players list
        ...(_availablePlayers.map((player) => _PlayerTile(
          player: player,
          onTap: () {
            setState(() {
              player['isSelected'] = !player['isSelected'];
            });
          },
        )).toList()),
      ],
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final Map<String, dynamic> player;
  final VoidCallback onTap;

  const _PlayerTile({
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = player['isSelected'];
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  player['avatar'],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: isSelected ? Colors.blue[800] : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Handicap: ${player['handicap']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      color: isSelected ? Colors.blue[600] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 24,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey[400],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}