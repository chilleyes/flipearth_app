import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';

class GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 85, // Account for iOS home indicator
          padding: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: PhosphorIcons.magnifyingGlass(),
                activeIcon: PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.fill),
                label: '搜索',
                isSelected: currentIndex == 0,
                onTap: () => onTabSelected(0),
              ),
              _NavBarItem(
                icon: PhosphorIcons.magicWand(),
                activeIcon: PhosphorIcons.magicWand(PhosphorIconsStyle.fill),
                label: '规划',
                isSelected: currentIndex == 1,
                onTap: () => onTabSelected(1),
              ),
              _NavBarItem(
                icon: PhosphorIcons.suitcase(),
                activeIcon: PhosphorIcons.suitcase(PhosphorIconsStyle.fill),
                label: '行程',
                isSelected: currentIndex == 2,
                onTap: () => onTabSelected(2),
              ),
              _NavBarItem(
                icon: PhosphorIcons.ticket(),
                activeIcon: PhosphorIcons.ticket(PhosphorIconsStyle.fill),
                label: '车票',
                isSelected: currentIndex == 3,
                onTap: () => onTabSelected(3),
              ),
              _NavBarItem(
                icon: PhosphorIcons.user(),
                activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
                label: '我的',
                isSelected: currentIndex == 4,
                onTap: () => onTabSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.textMain : AppColors.textMuted;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Icon(
              isSelected ? activeIcon : icon,
              key: ValueKey<bool>(isSelected),
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
