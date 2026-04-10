import 'package:absensi_raditya/page/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:absensi_raditya/api/preferences.dart';
import 'package:absensi_raditya/page/profile.dart';
import 'package:absensi_raditya/theme/app_theme.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          bottom: 25,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TimeDisplay(),
            Row(
              children: [
                _ThemeToggleButton(),
                const SizedBox(width: 10),
                _ProfileAvatar(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Jam & Tanggal yang update tiap detik
class _TimeDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, d MMMM', 'id_ID').format(DateTime.now()),
              style: const TextStyle(
                color: AppColors.primaryYellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('HH:mm', 'id_ID').format(DateTime.now()),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tombol toggle tema gelap/terang
class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryYellow.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              RotationTransition(turns: animation, child: child),
          child: Icon(
            themeProvider.isDark
                ? Icons.wb_sunny_rounded
                : Icons.nightlight_round,
            key: ValueKey(themeProvider.isDark),
            color: AppColors.primaryYellow,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Avatar profil yang menuju ProfilePage
class _ProfileAvatar extends StatefulWidget {
  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  late Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = AuthPreferences.getUserData(); // ✅ dipanggil sekali saja
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        String? photoUrl = snapshot.data?['profile_photo_url'];

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryYellow, width: 2.5),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                  ? NetworkImage(photoUrl)
                  : null,
              child: (photoUrl == null || photoUrl.isEmpty)
                  ? const Icon(
                      Icons.person,
                      color: AppColors.primaryBlue,
                      size: 30,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
