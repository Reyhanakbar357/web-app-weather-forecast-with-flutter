import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weather_app/core/themes/app_theme.dart';
import 'package:weather_app/core/utils/responsive_utils.dart';
import 'package:weather_app/presentation/widgets/responsive_layout.dart';
import 'compare_page.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'radar_page.dart';
import 'settings_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  MainScaffoldState createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navAnim;

  void switchTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _navAnim.forward(from: 0);
  }

  static const _pages = [
    HomePage(),
    MapPage(),
    RadarPage(),
    ComparePage(),
    FavoritesPage(),
    SettingsPage(),
  ];

  static const _navItems = [
    _NavItem(Icons.home_rounded, Icons.home_outlined, 'Beranda'),
    _NavItem(Icons.map_rounded, Icons.map_outlined, 'Peta'),
    _NavItem(Icons.radar_rounded, Icons.radar_outlined, 'Radar'),
    _NavItem(Icons.compare_arrows_rounded, Icons.compare_arrows_outlined, 'Banding'),
    _NavItem(Icons.favorite_rounded, Icons.favorite_border_rounded, 'Favorit'),
    _NavItem(Icons.settings_rounded, Icons.settings_outlined, 'Setelan'),
  ];

  @override
  void initState() {
    super.initState();
    _navAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _navAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indexedStack = IndexedStack(index: _currentIndex, children: _pages);

    return Scaffold(
      backgroundColor: AppColors.bg1,
      extendBody: true,
      body: ResponsiveLayout(
        mobile: indexedStack,
        tablet: Row(
          children: [
            _SideNavBar(
              currentIndex: _currentIndex,
              onTap: switchTab,
              isExpanded: false,
            ),
            Expanded(child: indexedStack),
          ],
        ),
        desktop: Row(
          children: [
            _SideNavBar(
              currentIndex: _currentIndex,
              onTap: switchTab,
              isExpanded: true,
            ),
            Expanded(child: indexedStack),
          ],
        ),
      ),
      bottomNavigationBar: ResponsiveLayout.isMobile(context)
          ? _FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: switchTab,
            )
          : null,
    );
  }
}

class _NavItem {
  final IconData activeIcon, icon;
  final String label;
  const _NavItem(this.activeIcon, this.icon, this.label);
}

// ── DESKTOP/TABLET SIDE BAR ──────────────────────────────────
class _SideNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isExpanded;
  
  const _SideNavBar({
    required this.currentIndex, 
    required this.onTap,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExpanded ? 220 : 80,
      decoration: BoxDecoration(
        color: const Color(0xFF07091C).withAlphaSafe(0.95),
        border: Border(right: BorderSide(color: Colors.white.withAlphaSafe(0.08))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo / Header
          Icon(Icons.cloud_circle_rounded, color: AppColors.cyan, size: isExpanded ? 48 : 36)
              .animate().fadeIn(duration: 800.ms).scale(),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            const Text('SkyView Pro', 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ],
          const SizedBox(height: 50),
          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: MainScaffoldState._navItems.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final selected = i == currentIndex;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 0, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.cyan.withAlphaSafe(0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: selected ? Border.all(color: AppColors.cyan.withAlphaSafe(0.3)) : Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected ? AppColors.cyan : AppColors.textMuted,
                          size: 22,
                        ),
                        if (isExpanded) ...[
                          const SizedBox(width: 14),
                          Text(item.label, style: TextStyle(
                            color: selected ? AppColors.cyan : AppColors.textMuted,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          )),
                        ]
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── MOBILE FLOATING PILL NAV BAR ─────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF07091C).withAlphaSafe(0.88),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withAlphaSafe(0.10)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlphaSafe(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 8)),
                  BoxShadow(
                      color: AppColors.cyan.withAlphaSafe(0.05),
                      blurRadius: 20,
                      spreadRadius: 1),
                ],
              ),
              child: Row(
                children: MainScaffoldState._navItems.asMap().entries.map((e) {
                  final i = e.key;
                  final item = e.value;
                  final selected = i == currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.cyan.withAlphaSafe(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                selected ? item.activeIcon : item.icon,
                                key: ValueKey(selected),
                                size: RS.fontSize(context, 20),
                                color: selected
                                    ? AppColors.cyan
                                    : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                  fontSize: RS.fontSize(context, 9),
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: selected
                                      ? AppColors.cyan
                                      : AppColors.textMuted),
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1.0, curve: Curves.easeOutCubic, duration: 600.ms)
     .fadeIn(duration: 400.ms);
  }
}
