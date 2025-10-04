import 'package:flutter/material.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  String? selectedCourse;
  DateTime? selectedDate;
  int selectedPlayers = 0;
  String? selectedTimeSlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20), // Reduced safe area spacing
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text(
                  'Book Tee Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Booking Details Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text(
                  'Booking details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _BookingDetailsWidget(
                selectedCourse: selectedCourse,
                selectedDate: selectedDate,
                selectedPlayers: selectedPlayers,
                onCourseChanged: (course) {
                  setState(() {
                    selectedCourse = course;
                  });
                },
                onDateChanged: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
                onPlayersChanged: (players) {
                  setState(() {
                    selectedPlayers = players;
                    selectedTimeSlot = null; // Clear time slot when players change
                  });
                },
              ),
              const SizedBox(height: 20),
              // Available Time Slots
              if (selectedCourse != null && selectedDate != null && selectedPlayers > 0) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    'Available times',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _TimeSlotGrid(
                  selectedPlayers: selectedPlayers,
                  onTimeSlotSelected: (timeSlot) {
                    setState(() {
                      selectedTimeSlot = timeSlot;
                    });
                  },
                ),
                const SizedBox(height: 20),
              ],
              // Book Button - only show when all details are selected and a time slot is chosen
              if (selectedCourse != null && selectedDate != null && selectedPlayers > 0 && selectedTimeSlot != null)
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement booking logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking tee time at $selectedTimeSlot on ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at $selectedCourse for $selectedPlayers player${selectedPlayers > 1 ? 's' : ''}'),
                          backgroundColor: const Color(0xFF3F768E),
                          duration: const Duration(seconds: 3),
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
                      'Book Tee Time',
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
      ),
    );
  }
}

class _BookingDetailsWidget extends StatelessWidget {
  final String? selectedCourse;
  final DateTime? selectedDate;
  final int selectedPlayers;
  final Function(String?) onCourseChanged;
  final Function(DateTime) onDateChanged;
  final Function(int) onPlayersChanged;

  const _BookingDetailsWidget({
    required this.selectedCourse,
    required this.selectedDate,
    required this.selectedPlayers,
    required this.onCourseChanged,
    required this.onDateChanged,
    required this.onPlayersChanged,
  });

  // Available courses for booking
  List<Map<String, dynamic>> get _courses {
    return [
      {
        'courseName': 'Stockholms Golfklubb',
        'location': 'Kevinge Strand, Danderyd',
        'distance': '1.2 miles',
        'price': 'Available',
        'imageUrl': 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=400&h=250&fit=crop',
      },
      {
        'courseName': 'Pebble Beach Golf Links',
        'location': 'Pebble Beach, CA',
        'distance': '2.3 miles',
        'price': '\$420',
        'imageUrl': 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=400&h=250&fit=crop',
      },
      {
        'courseName': 'TPC Sawgrass',
        'location': 'Ponte Vedra Beach, FL',
        'distance': '3.1 miles',
        'price': '\$295',
        'imageUrl': 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=400&h=250&fit=crop',
      },
      {
        'courseName': 'Augusta National Golf Club',
        'location': 'Augusta, GA',
        'distance': '4.5 miles',
        'price': 'Private',
        'imageUrl': 'https://images.unsplash.com/photo-1593111774240-d529f12cf4bb?w=400&h=250&fit=crop',
      },
      {
        'courseName': 'St. Andrews Links',
        'location': 'Scotland, UK',
        'distance': '5.7 miles',
        'price': '£180',
        'imageUrl': 'https://images.unsplash.com/photo-1587174486073-ae5e5cad7d8d?w=400&h=250&fit=crop',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Course Selection
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.golf_course,
                      color: const Color(0xFF3F768E),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Golf Course',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (selectedCourse == null)
                  GestureDetector(
                    onTap: () => _showCourseSelection(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Select golf course',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _showCourseSelection(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F768E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3F768E).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          // Course Logo/Icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[100],
                            ),
                            child: selectedCourse == 'Stockholms Golfklubb'
                                ? ClipOval(
                                    child: Image.network(
                                      'https://stockholmsgolfklubb.se/wp-content/uploads/2020/01/SGK_logo_green.png',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.golf_course,
                                          color: const Color(0xFF3F768E),
                                          size: 20,
                                        );
                                      },
                                    ),
                                  )
                                : selectedCourse == 'Pebble Beach Golf Links'
                                    ? ClipOval(
                                        child: Image.network(
                                          'https://www.pebblebeach.com/content/uploads/2019/04/PB-Golf-Links-Logo-2019.png',
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.golf_course,
                                              color: const Color(0xFF3F768E),
                                              size: 20,
                                            );
                                          },
                                        ),
                                      )
                                    : selectedCourse == 'TPC Sawgrass'
                                        ? ClipOval(
                                            child: Image.network(
                                              'https://tpc.com/sawgrass/images/tpc-sawgrass-logo.png',
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.golf_course,
                                                  color: const Color(0xFF3F768E),
                                                  size: 20,
                                                );
                                              },
                                            ),
                                          )
                                        : Icon(
                                            Icons.golf_course,
                                            color: const Color(0xFF3F768E),
                                            size: 20,
                                          ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedCourse!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _courses.firstWhere((course) => course['courseName'] == selectedCourse)['location'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                    fontFamily: 'Inter',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: const Color(0xFF3F768E),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Date Selection
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                onDateChanged(date);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: const Color(0xFF3F768E),
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Select date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: selectedDate != null ? Colors.black : Colors.grey[600],
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Players Selection
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  color: const Color(0xFF3F768E),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Players',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$selectedPlayers player${selectedPlayers > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: selectedPlayers > 1 ? () => onPlayersChanged(selectedPlayers - 1) : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedPlayers > 1 ? Colors.grey[200] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.remove,
                          color: selectedPlayers > 1 ? Colors.black : Colors.grey[400],
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      selectedPlayers.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: selectedPlayers < 4 ? () => onPlayersChanged(selectedPlayers + 1) : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedPlayers < 4 ? Colors.grey[200] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add,
                          color: selectedPlayers < 4 ? Colors.black : Colors.grey[400],
                          size: 16,
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
    );
  }

  void _showCourseSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Golf Course',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Inter',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Course list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  final isSelected = selectedCourse == course['courseName'];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        onCourseChanged(course['courseName']);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF3F768E).withOpacity(0.1) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected 
                            ? Border.all(color: const Color(0xFF3F768E).withOpacity(0.3), width: 2)
                            : Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            // Course Logo/Icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.grey[100],
                              ),
                              child: course['courseName'] == 'Stockholms Golfklubb'
                                  ? ClipOval(
                                      child: Image.network(
                                        'https://stockholmsgolfklubb.se/wp-content/uploads/2020/01/SGK_logo_green.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.golf_course,
                                            color: const Color(0xFF3F768E),
                                            size: 25,
                                          );
                                        },
                                      ),
                                    )
                                  : course['courseName'] == 'Pebble Beach Golf Links'
                                      ? ClipOval(
                                          child: Image.network(
                                            'https://www.pebblebeach.com/content/uploads/2019/04/PB-Golf-Links-Logo-2019.png',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.golf_course,
                                                color: const Color(0xFF3F768E),
                                                size: 25,
                                              );
                                            },
                                          ),
                                        )
                                      : course['courseName'] == 'TPC Sawgrass'
                                          ? ClipOval(
                                              child: Image.network(
                                                'https://tpc.com/sawgrass/images/tpc-sawgrass-logo.png',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.golf_course,
                                                    color: const Color(0xFF3F768E),
                                                    size: 25,
                                                  );
                                                },
                                              ),
                                            )
                                          : Icon(
                                              Icons.golf_course,
                                              color: const Color(0xFF3F768E),
                                              size: 25,
                                            ),
                            ),
                            const SizedBox(width: 16),
                            // Course Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Price
                            if (course['price'] == 'Available')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3F768E),
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
                              )
                            else if (course['price'] == 'Private')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[600],
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
                              )
                            else
                              Text(
                                course['price'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3F768E),
                                  fontFamily: 'Inter',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotGrid extends StatefulWidget {
  final Function(String?) onTimeSlotSelected;
  final int selectedPlayers;

  const _TimeSlotGrid({
    required this.onTimeSlotSelected,
    required this.selectedPlayers,
  });

  @override
  State<_TimeSlotGrid> createState() => _TimeSlotGridState();
}

class _TimeSlotGridState extends State<_TimeSlotGrid> {
  String? selectedTimeSlot;
  PageController _pageController = PageController();
  int _currentPage = 0;

  // Generate time slots from 10:00 to 16:50 in 10-minute intervals
  List<String> get _timeSlots {
    List<String> slots = [];
    for (int hour = 10; hour <= 16; hour++) {
      for (int minute = 0; minute < 60; minute += 10) {
        // Stop at 16:50
        if (hour == 16 && minute > 50) break;
        
        String timeSlot = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        slots.add(timeSlot);
      }
    }
    return slots;
  }

  // Check if slot is available for the selected number of players
  bool _isSlotAvailable(String timeSlot) {
    final bookedSpots = _getBookedSpots(timeSlot);
    final availableSpots = 4 - bookedSpots; // 4 total spots per slot
    return availableSpots >= widget.selectedPlayers;
  }

  // Get price for a time slot (varies by time)
  String _getSlotPrice(String timeSlot) {
    final hour = int.parse(timeSlot.split(':')[0]);
    if (hour >= 10 && hour < 12) return '\$45';
    if (hour >= 12 && hour < 14) return '\$55';
    if (hour >= 14 && hour < 16) return '\$65';
    return '\$50';
  }

  // Get number of booked spots for a time slot (0-4)
  int _getBookedSpots(String timeSlot) {
    // Simulate different booking levels for demo
    final slots = {
      '10:00': 1, '10:10': 3, '10:20': 0, '10:30': 4, '10:40': 2,
      '11:00': 2, '11:10': 1, '11:20': 4, '11:30': 0, '11:40': 3,
      '12:00': 4, '12:10': 2, '12:20': 1, '12:30': 3, '12:40': 0,
    };
    return slots[timeSlot] ?? (timeSlot.hashCode % 5); // Random for others
  }

  @override
  Widget build(BuildContext context) {
    final slots = _timeSlots;
    final slotsPerRow = 5;
    final maxVisibleRows = 3;
    final slotsPerPage = slotsPerRow * maxVisibleRows; // 15 slots per page
    final totalPages = (slots.length / slotsPerPage).ceil();
    
    return Column(
      children: [
        Container(
          height: 250, // Increased height for taller time slots with details
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: totalPages,
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * slotsPerPage;
              final endIndex = (startIndex + slotsPerPage).clamp(0, slots.length);
              final pageSlots = slots.sublist(startIndex, endIndex);
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: List.generate(maxVisibleRows, (rowIndex) {
                    final rowStartIndex = rowIndex * slotsPerRow;
                    final rowEndIndex = (rowStartIndex + slotsPerRow).clamp(0, pageSlots.length);
                    
                    if (rowStartIndex >= pageSlots.length) {
                      return Container(height: 75); // Match the new time slot height
                    }
                    
                    final rowSlots = pageSlots.sublist(rowStartIndex, rowEndIndex);
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: rowIndex < maxVisibleRows - 1 ? 8 : 0), // Reduced spacing between rows
                      child: Row(
                        children: [
                          ...rowSlots.map((timeSlot) {
                            final isAvailable = _isSlotAvailable(timeSlot);
                            final isSelected = selectedTimeSlot == timeSlot;
                            
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: isAvailable ? () {
                                    setState(() {
                                      selectedTimeSlot = isSelected ? null : timeSlot;
                                    });
                                    widget.onTimeSlotSelected(isSelected ? null : timeSlot);
                                  } : null,
                                  child: Container(
                                    height: 75, // Increased height for additional details
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? const Color(0xFF3F768E)
                                          : isAvailable 
                                              ? Colors.white
                                              : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF3F768E)
                                            : isAvailable
                                                ? Colors.grey[300]!
                                                : Colors.grey[300]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Time
                                          Text(
                                            timeSlot,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Inter',
                                              color: isSelected
                                                  ? Colors.white
                                                  : isAvailable
                                                      ? Colors.black
                                                      : Colors.grey[500],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Price
                                          Text(
                                            _getSlotPrice(timeSlot),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Inter',
                                              color: isSelected
                                                  ? Colors.white.withOpacity(0.9)
                                                  : isAvailable
                                                      ? Colors.grey[600]
                                                      : Colors.grey[400],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Availability circles (4 spots)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: List.generate(4, (index) {
                                              final bookedSpots = _getBookedSpots(timeSlot);
                                              final isSpotBooked = index < bookedSpots;
                                              return Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isSpotBooked
                                                      ? (isSelected ? Colors.white : const Color(0xFF3F768E))
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color: isSelected 
                                                        ? Colors.white.withOpacity(0.7)
                                                        : const Color(0xFF3F768E).withOpacity(0.7),
                                                    width: 1,
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          // Fill remaining slots in row with empty containers
                          ...List.generate(slotsPerRow - rowSlots.length, (index) => 
                            Expanded(child: Container())
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
        // Page indicators
        if (totalPages > 1) ...[
          const SizedBox(height: 4), // Reduced spacing between grid and dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index 
                      ? const Color(0xFF3F768E) 
                      : Colors.grey[300],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Swipe to see more times',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}