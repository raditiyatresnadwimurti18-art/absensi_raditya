import 'package:flutter/material.dart';
import 'package:absensi_raditya/models/absen_inout.dart';
import 'package:absensi_raditya/theme/app_theme.dart';

class StatusGrid extends StatelessWidget {
  final AttendanceData? todayAttendance;

  const StatusGrid({super.key, required this.todayAttendance});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            title: "Masuk",
            time: todayAttendance?.checkInTime ?? "--:--",
            icon: Icons.login_rounded,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _InfoCard(
            title: "Pulang",
            time: todayAttendance?.checkOutTime ?? "--:--",
            icon: Icons.logout_rounded,
            color: AppColors.primaryYellow,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: appColors.subText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
