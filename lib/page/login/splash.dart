import 'package:absensi_raditya/page/navigator_page/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:absensi_raditya/api/preferences.dart';
import 'package:absensi_raditya/page/login/login.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _checkLogin();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    }
  }

  void _checkLogin() async {
    // Durasi tunggu 3 detik
    await Future.delayed(const Duration(seconds: 3));

    bool isLogin = await AuthPreferences.isLoggedIn();

    if (!mounted) return;

    if (isLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // MENGGUNAKAN PUTIH AGAR MENYATU DENGAN BACKGROUND LOGO
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: _scale,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(seconds: 1),
                    child: Image.asset(
                      'assets/images/logo.png', // Sesuaikan path asset kamu
                      width: 220, // Ukuran sedikit diperbesar agar ikonik
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Indikator loading dengan warna biru yang diambil dari logo
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 1500),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF0074B7),
                      ), // Biru Logo
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tambahan teks kecil di bawah (opsional) untuk kesan profesional
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(seconds: 2),
                child: const Text(
                  "SECURE • SMART • ANONYM",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
