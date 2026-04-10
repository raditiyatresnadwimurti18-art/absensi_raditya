import 'package:flutter/material.dart';
import 'package:absensi_raditya/page/home_page.dart';
import 'package:absensi_raditya/page/history_page.dart';
import 'package:absensi_raditya/theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // Pakai PageView agar perpindahan halaman bisa di-animasi
  late final PageController _pageController;

  // Animasi untuk ikon yang aktif
  late final AnimationController _iconAnimController;
  late final Animation<double> _iconScaleAnim;

  final List<Widget> _pages = const [HomePage(), HistoryPage()];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
    _NavItem(icon: Icons.history_rounded, label: 'Riwayat'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _iconScaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _iconAnimController, curve: Curves.elasticOut),
    );
    _iconAnimController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconAnimController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
    // Reset & putar ulang animasi ikon
    _iconAnimController.reset();
    _iconAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: appColors.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // swipe dimatikan
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(appColors, isDark),
    );
  }

  Widget _buildBottomNav(AppColorExtension appColors, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: appColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        // Garis atas tipis sebagai aksen
        border: Border(
          top: BorderSide(
            color: AppColors.primaryBlue.withOpacity(isDark ? 0.3 : 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(index, appColors, isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, AppColorExtension appColors, bool isDark) {
    final bool isSelected = _selectedIndex == index;
    final item = _navItems[index];

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(isDark ? 0.25 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon dengan animasi scale saat dipilih
            isSelected
                ? ScaleTransition(
                    scale: _iconScaleAnim,
                    child: Icon(
                      item.icon,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                  )
                : Icon(item.icon, color: appColors.subText, size: 22),
            // Label muncul dengan animasi saat dipilih
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
