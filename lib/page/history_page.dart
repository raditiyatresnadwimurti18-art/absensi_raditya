import 'package:flutter/material.dart';
import 'package:absensi_raditya/api/controllers/attendance_controller.dart';
import 'package:absensi_raditya/models/riwayat_absen.dart';
import 'package:absensi_raditya/theme/app_theme.dart';
import 'package:absensi_raditya/widgets/history/history_card.dart';
import 'package:absensi_raditya/widgets/history/history_states.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.background,
      body: Stack(
        children: [
          _buildHeaderBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder<HistoryResponse>(
                    future: AttendanceController.getHistory(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return HistoryErrorState(
                          error: snapshot.error.toString(),
                          onRetry: () => setState(() {}),
                        );
                      }

                      final listHistory = snapshot.data?.data ?? [];

                      if (listHistory.isEmpty) {
                        return const HistoryEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async => setState(() {}),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          itemCount: listHistory.length,
                          itemBuilder: (context, index) {
                            return HistoryCard(item: listHistory[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, Color(0xFF005A8E)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
    );
  }
}
