import 'package:absensi_raditya/page/auth/splash.dart';
import 'package:absensi_raditya/providers/theme_provider.dart';
import 'package:absensi_raditya/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  await initializeDateFormatting('id_ID', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, // static — tanpa ()
      darkTheme: AppTheme.dark, // static — tanpa ()
      themeMode: themeProvider.themeMode,
      home: SplashPage(),
    );
  }
}
