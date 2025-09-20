import '../features/1b_user/presentation/user_page.dart';
import '../features/4_focus/presentation/focus_page.dart';
import '../features/2_group/presentation/group_page.dart';

import '../features/1_home/presentation/home_page.dart';
import 'package:flutter/material.dart';
import '../core/widgets/navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              const HomePage(),
              const GroupPage(),
              const FocusPage(),
              const UserPage(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(38, 0, 0, 0),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Navbar(
                  currentIndex: _selectedIndex,
                  onTap: _onNavTapped,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavTapped(int index) {
    _pageController.jumpToPage(index);
    setState(() => _selectedIndex = index);
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }
}
