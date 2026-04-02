import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/providers/app_state.dart';

class AbsensiApp extends StatelessWidget {
  const AbsensiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ABSENSI PPKD',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.themeMode,
          home: _buildHome(appState),
        );
      },
    );
  }

  Widget _buildHome(AppState appState) {
    if (!appState.isReady) {
      return const SplashPage();
    }

    if (appState.isLoggedIn) {
      return const DashboardPage();
    }

    return const LoginPage();
  }
}
