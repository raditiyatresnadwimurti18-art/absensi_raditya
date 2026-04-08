// lib/view/splash_page.dart
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
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    bool isLogin = await AuthPreferences.isLoggedIn();

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
    return const Scaffold(body: Center(child: Text("Loading...")));
  }
}
