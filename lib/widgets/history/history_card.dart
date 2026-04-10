import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:absensi_raditya/models/riwayat_absen.dart';
import 'package:absensi_raditya/theme/app_theme.dart';

class HistoryCard extends StatelessWidget {
  final HistoryData item;

  const HistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final bool isIzin = item.status?.toLowerCase() == "izin";
    final Color statusColor = isIzin ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: appColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Garis status di samping
              Container(width: 6, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(item.attendanceDate),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: appColors.text,
                            ),
                          ),
                          _StatusBadge(
                            label: item.status?.toUpperCase() ?? "-",
                            color: statusColor,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: appColors.subText.withOpacity(0.2),
                        ),
                      ),
                      Row(
                        children: [
                          _TimeInfo(
                            label: "MASUK",
                            time: item.checkInTime ?? "--:--",
                            icon: Icons.login_rounded,
                            color: Colors.green,
                          ),
                          const Spacer(),
                          _TimeInfo(
                            label: "PULANG",
                            time: item.checkOutTime ?? "--:--",
                            icon: Icons.logout_rounded,
                            color: Colors.redAccent,
                          ),
                          const Spacer(),
                          _TimeInfo(
                            label: "DETAIL",
                            time: isIzin ? "IZIN" : "HADIR",
                            icon: Icons.info_outline_rounded,
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      ),
                      if (isIzin && item.alasanIzin != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            "Ket: ${item.alasanIzin}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[800],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _TimeInfo({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: appColors.subText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: appColors.text,
          ),
        ),
      ],
    );
  }
}
