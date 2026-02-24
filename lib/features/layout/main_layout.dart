import 'package:flutter/material.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/theme/app_colors.dart';
import '../planner/planner_page.dart';
import '../explore/explore_page.dart';
import '../trips/my_trips_page.dart';
import '../tickets/my_tickets_page.dart';
import '../profile/profile_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 1; // Default to Planner

  // Dummy pages for now, later we will replace with actual feature pages
  final List<Widget> _pages = [
    const ExplorePage(), // <-- Explore Page hooked up
    const PlannerPage(), // <-- The new Hero Planner Page
    const MyTripsPage(), // <-- My Trips Page hooked up
    const MyTicketsPage(), // <-- My Tickets Page hooked up
    const ProfilePage(),  // <-- Profile Page hooked up
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // This is crucial for the Glass Nav to overlap the content
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabTapped,
      ),
    );
  }
}


