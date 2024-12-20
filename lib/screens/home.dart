import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/explore.dart';
import '../screens/statistics.dart';
import '../screens/notifications.dart';
import '../screens/profile.dart';
import '../screens/discover.dart';
import '../screens/cart.dart';
import '../screens/reels.dart';
import '../screens/feed.dart';
import '../screens/wishlist.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();

  final List<String> _titles = [
    'Discover',
    'Explore',
    'Earnings',
    'Feed',
    'Profile',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedTabIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              children: [
                DiscoverScreen(),
                ExploreScreen(),
                StatisticsScreen(),
                ReelScreen(),
                ProfileScreen(),
              ],
            ),
          ),
          BottomNavigationBarWidget(
            currentIndex: _selectedTabIndex,
            onTap: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
              _pageController.jumpToPage(index);
            },
          ),
        ],
      ),
    );
  }
}