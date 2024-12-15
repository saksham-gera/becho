import 'package:flutter/material.dart';
import 'welcome.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150'), // Placeholder image URL
              radius: 25,
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  'Alex',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ready for Today's Challenges?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterChip(label: Text('All'), onSelected: (_) {}, selected: true),
                FilterChip(label: Text('Alone'), onSelected: (_) {}, selected: false),
                FilterChip(label: Text('With Friends'), onSelected: (_) {}, selected: false),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 15, // Horizontal spacing between cards
                mainAxisSpacing: 15, // Vertical spacing between cards
                childAspectRatio: 0.8, // Adjust this value to suit your layout
                children: [
                  ActivityCard(
                    title: 'Running',
                    time: '7:00 AM',
                    color: Colors.blue,
                    friends: 1,
                  ),
                  ActivityCard(
                    title: 'Gym',
                    time: '8:00 PM',
                    color: Colors.indigo,
                    friends: 3,
                  ),
                  ActivityCard(
                    title: 'Meditation',
                    time: '10:30 PM',
                    color: Colors.green,
                    friends: 0,
                  ),
                  AddActivityCard(),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow modal to adjust height based on content
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the bottom sheet
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the bottom sheet
                        _logout(context); // Proceed with logout
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _logout(BuildContext context) {
    // Here you can add your logout logic. For example, clearing user session data,
    // removing authentication tokens, or navigating to the login screen.

    // Example of navigating to a login screen (you can replace this with your actual login screen).
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String title;
  final String time;
  final Color color;
  final int friends;

  ActivityCard({required this.title, required this.time, required this.color, required this.friends});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (friends > 0)
              Stack(
                children: List.generate(friends, (index) {
                  return Positioned(
                    left: index * 20.0,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://via.placeholder.com/100'), // Friend placeholder
                      radius: 12,
                    ),
                  );
                }),
              ),
            if (friends == 0)
              CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://via.placeholder.com/100'), // Single placeholder
                radius: 12,
              ),
            Spacer(),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class AddActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(Icons.add, size: 40, color: Colors.grey[700]),
      ),
    );
  }
}