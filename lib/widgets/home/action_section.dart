import 'package:flutter/material.dart';
import 'package:absensi_raditya/models/absen_inout.dart';
import 'package:absensi_raditya/theme/app_theme.dart';

class ActionSection extends StatelessWidget {
  final bool isLoading;
  final bool isLoadingAttendance;
  final AttendanceData? todayAttendance;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onIzin;
  final VoidCallback onDelete;

  const ActionSection({
    super.key,
    required this.isLoading,
    required this.isLoadingAttendance,
    required this.todayAttendance,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onIzin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingAttendance) {
      return const Center(child: CircularProgressIndicator());
    }

    final bool hasDataToday = todayAttendance != null;
    final bool hasCheckIn = todayAttendance?.checkInTime != null;
    final bool hasCheckOut = todayAttendance?.checkOutTime != null;
    final bool isIzin = todayAttendance?.status?.toLowerCase() == "izin";

    return Column(
      children: [
        // Status utama / tombol aksi
        if (isIzin)
          _StatusTile(message: "Anda sedang Izin/Sakit", color: Colors.orange)
        else if (hasCheckOut)
          _StatusTile(message: "Presensi hari ini selesai", color: Colors.green)
        else if (hasCheckIn)
          _MainActionButton(
            text: "CHECK OUT PULANG",
            color: const Color(0xFFE53935),
            icon: Icons.power_settings_new_rounded,
            isLoading: isLoading,
            onPressed: onCheckOut,
          )
        else
          Column(
            children: [
              _MainActionButton(
                text: "CHECK IN MASUK",
                color: AppColors.primaryBlue,
                icon: Icons.fingerprint_rounded,
                isLoading: isLoading,
                onPressed: onCheckIn,
              ),
              const SizedBox(height: 12),
              _SecondaryActionButton(
                text: "Izin / Sakit",
                isLoading: isLoading,
                onPressed: onIzin,
              ),
            ],
          ),

        // Tombol hapus — hanya muncul jika ada data hari ini
        if (hasDataToday) ...[
          const SizedBox(height: 24),
          Divider(color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 8),
          _DeleteButton(isLoading: isLoading, onPressed: onDelete),
        ],
      ],
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────

class _StatusTile extends StatelessWidget {
  final String message;
  final Color color;

  const _StatusTile({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: color, size: 40),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  const _MainActionButton({
    required this.text,
    required this.color,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, color: Colors.white, size: 30),
        label: Text(
          isLoading ? "MEMPROSES..." : text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SecondaryActionButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppColors.primaryBlue.withOpacity(0.3),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _DeleteButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(
        Icons.delete_sweep_outlined,
        color: Colors.red.withOpacity(0.8),
      ),
      label: Text(
        "Hapus Data Hari Ini",
        style: TextStyle(
          color: Colors.red.withOpacity(0.8),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
