import 'package:flutter/material.dart';
import 'profile_settings_page.dart';

class YouPage extends StatelessWidget {
  const YouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main picture section (like HomePage)
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/you_page_hero.webp'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Stack(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 0),
                          // Profile and handicap row
                          Row(
                            children: [
                              // User profile picture
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    'https://media.licdn.com/dms/image/v2/C4D03AQGaqt95NNb4UQ/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1516782855402?e=1761782400&v=beta&t=S-xAJxOYW6H6jSkzSHMV85kwEUtztSZ5_2YjPq51TBY',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF2E7D32),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Handicap display
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'HCP 16.6',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Settings icon with dropdown menu
                              PopupMenuButton<int>(
                                icon: const Icon(Icons.settings, color: Colors.white),
                                color: Colors.white,
                                onSelected: (value) {
                                  switch (value) {
                                    case 0:
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ProfileSettingsPage(),
                                        ),
                                      );
                                      break;
                                    case 1:
                                      // Notifications
                                      // TODO: Implement navigation to notifications page
                                      break;
                                    case 2:
                                      // App Settings
                                      // TODO: Implement navigation to app settings page
                                      break;
                                    case 3:
                                      // Help & Support
                                      // TODO: Implement navigation to help & support page
                                      break;
                                    case 4:
                                      // Sign Out
                                      // TODO: Implement sign out logic
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem<int>(
                                    value: 0,
                                    child: ListTile(
                                      leading: Icon(Icons.person),
                                      title: Text('Profile Settings'),
                                    ),
                                  ),
                                  const PopupMenuItem<int>(
                                    value: 1,
                                    child: ListTile(
                                      leading: Icon(Icons.notifications),
                                      title: Text('Notifications'),
                                    ),
                                  ),
                                  const PopupMenuItem<int>(
                                    value: 2,
                                    child: ListTile(
                                      leading: Icon(Icons.settings),
                                      title: Text('App Settings'),
                                    ),
                                  ),
                                  const PopupMenuItem<int>(
                                    value: 3,
                                    child: ListTile(
                                      leading: Icon(Icons.help),
                                      title: Text('Help & Support'),
                                    ),
                                  ),
                                  const PopupMenuItem<int>(
                                    value: 4,
                                    child: ListTile(
                                      leading: Icon(Icons.logout),
                                      title: Text('Sign Out'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // App logo/title
                          const Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 21,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'You are hitting the fairway 89% of the times',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // You can add more overlays here if needed (e.g., friends counter)
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Statistics & Menu with horizontal padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Statistics',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 0.85,
                    padding: EdgeInsets.zero,
                    children: const [
                      _StatCard(
                        title: 'Rounds',
                        value: '47',
                        icon: Icons.sports_golf,
                        color: Colors.blue,
                        iconSize: 22,
                        valueFontSize: 16,
                        titleFontSize: 10,
                      ),
                      _StatCard(
                        title: 'Best Score',
                        value: '82',
                        icon: Icons.emoji_events,
                        color: Colors.orange,
                        iconSize: 22,
                        valueFontSize: 16,
                        titleFontSize: 10,
                      ),
                      _StatCard(
                        title: 'Courses',
                        value: '12',
                        icon: Icons.golf_course,
                        color: Colors.green,
                        iconSize: 22,
                        valueFontSize: 16,
                        titleFontSize: 10,
                      ),
                      _StatCard(
                        title: 'Avg. Score',
                        value: '89',
                        icon: Icons.trending_down,
                        color: Colors.purple,
                        iconSize: 22,
                        valueFontSize: 16,
                        titleFontSize: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Menu Options
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Account',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _MenuTile(
                        icon: Icons.person,
                        title: 'Profile Settings',
                        subtitle: 'Edit your personal information',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileSettingsPage(),
                            ),
                          );
                        },
                      ),
                      const _MenuTile(
                        icon: Icons.history,
                        title: 'Game History',
                        subtitle: 'View your past rounds',
                      ),
                      const _MenuTile(
                        icon: Icons.favorite,
                        title: 'Favorite Courses',
                        subtitle: 'Manage your favorite golf courses',
                      ),
                      const _MenuTile(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        subtitle: 'Manage your notification preferences',
                      ),
                      const _MenuTile(
                        icon: Icons.settings,
                        title: 'App Settings',
                        subtitle: 'Configure app preferences',
                      ),
                      const _MenuTile(
                        icon: Icons.help,
                        title: 'Help & Support',
                        subtitle: 'Get help and contact support',
                      ),
                      const _MenuTile(
                        icon: Icons.logout,
                        title: 'Sign Out',
                        subtitle: 'Sign out of your account',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double iconSize;
  final double valueFontSize;
  final double titleFontSize;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.iconSize = 32,
    this.valueFontSize = 24,
    this.titleFontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: iconSize,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap ?? () {
          // TODO: Navigate to appropriate page
        },
      ),
    );
  }
}