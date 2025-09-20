import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Navbar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavItem(
          selected: currentIndex == 0,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
          onTap: () => onTap(0),
        ),
        _NavItem(
          selected: currentIndex == 1,
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'Group',
          onTap: () => onTap(1),
        ),
        _NavItem(
          selected: currentIndex == 2,
          icon: Icons.timer_outlined,
          selectedIcon: Icons.timer,
          label: 'Focus',
          onTap: () => onTap(2),
        ),
        _NavItem(
          selected: currentIndex == 3,
          icon: Icons.person_outlined,
          selectedIcon: Icons.person,
          label: 'User',
          onTap: () => onTap(3),
        ),
        // NavItem(
        //   selected: currentIndex == 4,
        //   icon: Icons.chat_outlined,
        //   selectedIcon: Icons.chat,
        //   label: 'Chat',
        //   onTap: () => onTap(4),
        // ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 24,
                color: selected ? Color(0xFF7B6EF2) : Colors.grey,
              ),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? Color(0xFF7B6EF2) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
