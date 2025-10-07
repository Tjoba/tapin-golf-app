import 'package:flutter/material.dart';
import 'round_page.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  String? selectedCourse;
  List<String> selectedPlayers = [];

  @override
  void initState() {
    super.initState();
    // Start with no players selected - user can manually select including themselves
    selectedPlayers = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60), // More safe area spacing
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Search golf course',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Search golf courses or locations...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Inter',
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey[500],
                      size: 22,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
            ),
            ),
            const SizedBox(height: 20),
            // Or select a favorite course text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Or select a favorite course',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Course List
            _CourseListView(
              selectedCourse: selectedCourse,
              onCourseSelected: (courseName) {
                setState(() {
                  selectedCourse = selectedCourse == courseName ? null : courseName;
                });
              },
            ),
            const SizedBox(height: 30),
            // Player Selection Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Select players',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PlayerSelectionWidget(
              selectedPlayers: selectedPlayers,
              onPlayersChanged: (players) {
                setState(() {
                  selectedPlayers = players;
                });
              },
            ),
            const SizedBox(height: 20),
            // Start Round Button - only show when course and players are selected
            if (selectedCourse != null && selectedPlayers.isNotEmpty)
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoundPage(
                          courseName: selectedCourse!,
                          selectedPlayers: selectedPlayers,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F768E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Round',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CourseListView extends StatelessWidget {
  final String? selectedCourse;
  final Function(String) onCourseSelected;
  
  const _CourseListView({
    required this.selectedCourse,
    required this.onCourseSelected,
  });

  // All available courses
  List<Map<String, dynamic>> get _courses {
    return [
      {
        'courseName': 'Stockholms Golfklubb',
        'location': 'Kevinge Strand, Danderyd',
        'distance': '1.2 miles',
        'rating': '4.6',
        'price': 'Booked',
        'imageUrl': 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=400&h=250&fit=crop',
      },
      {
        'courseName': 'Pebble Beach Golf Links',
        'location': 'Pebble Beach, CA',
        'distance': '2.3 miles',
        'rating': '4.8',
        'price': '\$420',
        'imageUrl': 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=400&h=250&fit=crop',
      },
      {
        'courseName': 'TPC Sawgrass',
        'location': 'Ponte Vedra Beach, FL',
        'distance': '12.4 miles',
        'rating': '4.9',
        'price': '\$350',
        'imageUrl': 'https://images.unsplash.com/photo-1593111774240-d529f12cf4bb?w=400&h=250&fit=crop',
      },


    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        final isSelected = selectedCourse == course['courseName'];
        return GestureDetector(
          onTap: () => onCourseSelected(course['courseName']),
          child: Container(
            margin: EdgeInsets.only(
              bottom: index == _courses.length - 1 ? 0 : 8,
            ),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Logo placeholder
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: (course['courseName'] == 'Stockholms Golfklubb' || course['courseName'] == 'Pebble Beach Golf Links' || course['courseName'] == 'TPC Sawgrass')
                            ? Colors.white 
                            : const Color(0xFF3F768E).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: course['courseName'] == 'Stockholms Golfklubb'
                          ? ClipOval(
                              child: Image.network(
                                'https://media.licdn.com/dms/image/v2/C4D0BAQFRMkoQyshsUA/company-logo_200_200/company-logo_200_200/0/1677945840570/stockholms_golfklubb_logo?e=1762387200&v=beta&t=wIU3CZN0igL__CSPwR5gxnrJsw9w_X2QNZEwzYOvz_g',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to default icon if image fails to load
                                  return Icon(
                                    Icons.golf_course,
                                    color: const Color(0xFF3F768E),
                                    size: 30,
                                  );
                                },
                              ),
                            )
                          : course['courseName'] == 'Pebble Beach Golf Links'
                          ? ClipOval(
                              child: Image.network(
                                'https://shop.pebblebeach.com/media/catalog/product/cache/f5145d18489ce367df032006b8df698d/i/m/img_5484.jpg',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to default icon if image fails to load
                                  return Icon(
                                    Icons.golf_course,
                                    color: const Color(0xFF3F768E),
                                    size: 30,
                                  );
                                },
                              ),
                            )
                          : course['courseName'] == 'TPC Sawgrass'
                          ? ClipOval(
                              child: Image.network(
                                'https://cdn.cookielaw.org/logos/90140a3f-c2e1-44aa-b1a3-0eefbfd83edf/9c14de9e-9717-4931-b060-3d5897dfe06d/bdf97a1f-f3c1-404d-bdfe-4434f11f1766/TPC_Mark_rgb.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to default icon if image fails to load
                                  return Icon(
                                    Icons.golf_course,
                                    color: const Color(0xFF3F768E),
                                    size: 30,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.golf_course,
                              color: const Color(0xFF3F768E),
                              size: 30,
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Course Info
                    Expanded(
                      child: Row(
                        children: [
                          // Left side: Course name and location
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  course['courseName'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Inter',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  course['location'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                    fontFamily: 'Inter',
                                    height: 1.0,
                                    letterSpacing: 0.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Right side: Price and rating
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Only show price for Stockholms Golfklubb when Booked
                              if (course['courseName'] == 'Stockholms Golfklubb' && course['price'] == 'Booked')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF77A3B6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    course['price'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              // Add spacing only if price is shown
                              if (course['courseName'] == 'Stockholms Golfklubb' && course['price'] == 'Booked')
                                const SizedBox(height: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Selection indicator
                    if (isSelected)
                      Container(
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
                  ],
                ),
              ),
            ),
          );
        },
      );
  }
}



class _PlayerSelectionWidget extends StatefulWidget {
  final List<String> selectedPlayers;
  final Function(List<String>) onPlayersChanged;
  
  const _PlayerSelectionWidget({
    required this.selectedPlayers,
    required this.onPlayersChanged,
  });
  
  @override
  State<_PlayerSelectionWidget> createState() => _PlayerSelectionWidgetState();
}

class _PlayerSelectionWidgetState extends State<_PlayerSelectionWidget> {
  final List<Map<String, dynamic>> _availablePlayers = [
    {'name': 'Tobias Hanner', 'handicap': '16.6', 'imageUrl': 'https://media.licdn.com/dms/image/v2/C4D03AQGaqt95NNb4UQ/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1516782855402?e=1761782400&v=beta&t=S-xAJxOYW6H6jSkzSHMV85kwEUtztSZ5_2YjPq51TBY', 'isCurrentUser': true}, // Logged in user
    {'name': 'Andreas Lantz', 'handicap': '12', 'imageUrl': 'https://media.licdn.com/dms/image/v2/C4E03AQFy5W-ZVRH00w/profile-displayphoto-shrink_400_400/profile-displayphoto-shrink_400_400/0/1519566998561?e=1762387200&v=beta&t=Yvf0kLDe1KIdv3hoP3UYtw0e7lUhpltV13pO4Y0sK1s'},
    {'name': 'Magnus Berg', 'handicap': '8'},
    {'name': 'Markus Ahlsen', 'handicap': '15'},
    {'name': 'Martin Hanner', 'handicap': '18', 'imageUrl': 'http://media.licdn.com/dms/image/v2/D4D03AQHmrJawzEWAlg/profile-displayphoto-shrink_400_400/profile-displayphoto-shrink_400_400/0/1730402790769?e=1762387200&v=beta&t=pG_FjugAmOaZgskQgvw4nElC5Q71uw2xMfJjhFPdw_8'},
    {'name': 'Pelle Holmstrom', 'handicap': '11'},
    {'name': 'Stefan Landfeldt', 'handicap': '14'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available players as round buttons in a horizontal scrolling row
          SizedBox(
            height: 100, // Fixed height for the scrolling area
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Add Friend button first
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _AddFriendButton(
                      onTap: () => _showAddFriendDialog(context),
                    ),
                  ),
                  // Tobias (logged-in user) second
                  ..._availablePlayers.where((player) => player['isCurrentUser'] == true).map((player) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _PlayerButton(
                      player: player,
                      isSelected: widget.selectedPlayers.contains(player['name']),
                      onTap: () {
                        List<String> updatedPlayers = List.from(widget.selectedPlayers);
                        if (updatedPlayers.contains(player['name'])) {
                          updatedPlayers.remove(player['name']);
                        } else {
                          // Only add if less than 4 players are selected
                          if (updatedPlayers.length < 4) {
                            updatedPlayers.add(player['name']);
                          }
                        }
                        widget.onPlayersChanged(updatedPlayers);
                      },
                    ),
                  )),
                  // Rest of the players
                  ..._availablePlayers.where((player) => player['isCurrentUser'] != true).map((player) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _PlayerButton(
                      player: player,
                      isSelected: widget.selectedPlayers.contains(player['name']),
                      onTap: () {
                        List<String> updatedPlayers = List.from(widget.selectedPlayers);
                        if (updatedPlayers.contains(player['name'])) {
                          updatedPlayers.remove(player['name']);
                        } else {
                          // Only add if less than 4 players are selected
                          if (updatedPlayers.length < 4) {
                            updatedPlayers.add(player['name']);
                          }
                        }
                        widget.onPlayersChanged(updatedPlayers);
                      },
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add Player',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Enter friend\'s name',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Inter'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  setState(() {
                    _availablePlayers.add({
                      'name': nameController.text.trim(),
                      'handicap': '0',
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(fontFamily: 'Inter'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlayerButton extends StatelessWidget {
  final Map<String, dynamic> player;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlayerButton({
    required this.player,
    required this.isSelected,
    required this.onTap,
  });

  String _getPlayerInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return nameParts[0][0].toUpperCase();
  }

  String _formatPlayerName(String fullName) {
    List<String> nameParts = fullName.split(' ');
    if (nameParts.length >= 2) {
      String firstName = nameParts[0];
      String lastInitial = nameParts[1][0].toUpperCase();
      return '$firstName $lastInitial.';
    }
    return nameParts[0]; // Return first name only if no last name
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = player['isCurrentUser'] == true;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Round button with avatar
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(
                    color: const Color(0xFF3F768E),
                    width: 3,
                  ) : null,
                ),
                child: Center(
                  child: player['imageUrl'] != null
                      ? ClipOval(
                          child: Image.network(
                            player['imageUrl'],
                            width: 66,
                            height: 66,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                _getPlayerInitials(player['name']),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3F768E),
                                ),
                              );
                            },
                          ),
                        )
                      : Text(
                          _getPlayerInitials(player['name']),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3F768E),
                          ),
                        ),
                ),
              ),
              // Current user indicator
              if (isCurrentUser)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F768E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Player name
          SizedBox(
            width: 80,
            child: Text(
              _formatPlayerName(player['name']), // Show first name + last initial
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w600,
                fontFamily: 'Inter',
                color: isSelected ? const Color(0xFF3F768E) : (isCurrentUser ? const Color(0xFF3F768E).withOpacity(0.8) : Colors.black),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFriendButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddFriendButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Round button with plus icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 30,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Add friend label
          const SizedBox(
            width: 80,
            child: Text(
              'Add Player',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}