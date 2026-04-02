import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_formatters.dart';
import '../../../data/models/attendance_model.dart';
import '../../providers/app_state.dart';
import '../history/history_page.dart';
import '../map/map_page.dart';
import '../profile/profile_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ABSENSI PPKD'),
          actions: [
            Consumer<AppState>(
              builder: (context, appState, _) {
                return IconButton(
                  onPressed: appState.toggleTheme,
                  icon: Icon(
                    appState.themeMode == ThemeMode.dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                );
              },
            ),
            Consumer<AppState>(
              builder: (context, appState, _) {
                return IconButton(
                  onPressed: () async {
                    await appState.logout();
                  },
                  icon: const Icon(Icons.logout),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Riwayat'),
              Tab(text: 'Profil'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DashboardTab(),
            HistoryPage(),
            ProfilePage(),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  Future<void> _submitAttendance(
    BuildContext context,
    Future<void> Function() action,
    String successLabel,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final appState = context.read<AppState>();

    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(successLabel)));
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(appState.errorMessage ?? 'Proses gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final user = appState.user;
        final stats = appState.stats;
        final today = stats.todayAttendance;

        return RefreshIndicator(
          onRefresh: appState.refreshAll,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E7490), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${user?.firstName ?? 'Peserta'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.fullDate.format(DateTime.now()),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: appState.isLoading
                                ? null
                                : () => _submitAttendance(
                                      context,
                                      appState.submitCheckIn,
                                      'Absen masuk berhasil',
                                    ),
                            icon: const Icon(Icons.login),
                            label: const Text('Absen Masuk'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: appState.isLoading
                                ? null
                                : () => _submitAttendance(
                                      context,
                                      appState.submitCheckOut,
                                      'Absen pulang berhasil',
                                    ),
                            icon: const Icon(Icons.logout),
                            label: const Text('Absen Pulang'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    title: 'Total Absen',
                    value: stats.totalAttendance.toString(),
                    icon: Icons.fact_check_outlined,
                  ),
                  _StatCard(
                    title: 'Total Check In',
                    value: stats.totalCheckIn.toString(),
                    icon: Icons.login,
                  ),
                  _StatCard(
                    title: 'Total Check Out',
                    value: stats.totalCheckOut.toString(),
                    icon: Icons.logout,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Absen Hari Ini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (today == null)
                        const Text('Belum ada absensi untuk hari ini.')
                      else
                        _AttendanceSummary(attendance: today),
                      const SizedBox(height: 16),
                      if (today?.latitude != null && today?.longitude != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonalIcon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MapPage(attendance: today!),
                                ),
                              );
                            },
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('Lihat Google Map'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 18),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceSummary extends StatelessWidget {
  const _AttendanceSummary({required this.attendance});

  final AttendanceModel attendance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal: ${attendance.date == null ? '-' : AppFormatters.shortDate.format(attendance.date!)}',
        ),
        const SizedBox(height: 8),
        Text(
          'Masuk: ${attendance.checkIn == null ? '-' : AppFormatters.time.format(attendance.checkIn!)}',
        ),
        const SizedBox(height: 8),
        Text(
          'Pulang: ${attendance.checkOut == null ? '-' : AppFormatters.time.format(attendance.checkOut!)}',
        ),
        const SizedBox(height: 8),
        Text(
          'Lokasi: ${attendance.latitude?.toStringAsFixed(6) ?? '-'}, ${attendance.longitude?.toStringAsFixed(6) ?? '-'}',
        ),
      ],
    );
  }
}
