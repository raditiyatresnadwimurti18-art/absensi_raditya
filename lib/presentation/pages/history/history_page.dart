import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_formatters.dart';
import '../../../data/models/attendance_model.dart';
import '../../providers/app_state.dart';
import '../map/map_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final history = appState.history;

        if (history.isEmpty) {
          return const Center(
            child: Text('Riwayat absensi belum tersedia.'),
          );
        }

        return RefreshIndicator(
          onRefresh: appState.refreshAll,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = history[index];
              return _HistoryCard(attendance: item);
            },
          ),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.attendance});

  final AttendanceModel attendance;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              attendance.date == null
                  ? '-'
                  : AppFormatters.shortDate.format(attendance.date!),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Jam masuk: ${attendance.checkIn == null ? '-' : AppFormatters.time.format(attendance.checkIn!)}',
            ),
            const SizedBox(height: 6),
            Text(
              'Jam keluar: ${attendance.checkOut == null ? '-' : AppFormatters.time.format(attendance.checkOut!)}',
            ),
            const SizedBox(height: 6),
            Text(
              'Lokasi: ${attendance.latitude?.toStringAsFixed(6) ?? '-'}, ${attendance.longitude?.toStringAsFixed(6) ?? '-'}',
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (attendance.latitude != null && attendance.longitude != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MapPage(attendance: attendance),
                        ),
                      );
                    },
                    icon: const Icon(Icons.location_on_outlined),
                    label: const Text('Map'),
                  ),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await appState.deleteAttendance(attendance.id);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Absensi berhasil dihapus')),
                      );
                    } catch (_) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            appState.errorMessage ?? 'Hapus absensi gagal',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
