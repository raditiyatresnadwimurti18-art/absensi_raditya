import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:absensi_raditya/api/preferences.dart';
import 'package:absensi_raditya/models/usermodel.dart';
import 'package:absensi_raditya/page/login/login.dart';
import 'package:absensi_raditya/api/controllers/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color primaryBlue = const Color(0xFF005DA9);
  final Color secondaryYellow = const Color(0xFFFFCC00);

  final ProfileController _controller = ProfileController();
  bool _isLoading = false;

  // --- LOGIKA UPDATE FOTO ---
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      // 1. Ambil Messenger sebelum async jika ingin sangat aman
      final messenger = ScaffoldMessenger.of(context);

      setState(() => _isLoading = true);
      final result = await _controller.updateUserPhoto(pickedFile.path);
      setState(() => _isLoading = false);

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Proses selesai"),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (result['success']) setState(() {});
    }
  }

  // --- LOGIKA EDIT NAMA ---
  void _showEditNameDialog(String currentName) {
    TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Nama Profil"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Nama Lengkap",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                // STRATEGI PERBAIKAN:
                // Simpan referensi messenger SEBELUM pop dialog
                final messenger = ScaffoldMessenger.of(context);

                Navigator.pop(dialogContext); // Tutup dialog

                setState(() => _isLoading = true);
                final result = await _controller.updateUserName(
                  nameController.text,
                );
                setState(() => _isLoading = false);

                // Pastikan widget utama masih ada di tree
                if (!mounted) return;

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? "Sukses"),
                    backgroundColor: result['success']
                        ? Colors.green
                        : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                if (result['success']) setState(() {});
              }
            },
            child: const Text("SIMPAN", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- LOGIKA LOGOUT ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await AuthPreferences.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              "YA, KELUAR",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Profil Pengguna",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: AuthPreferences.getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: Text("Data profil tidak ditemukan."),
                );
              }

              final userData = User.fromJson(snapshot.data!);

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: secondaryYellow,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: primaryBlue,
                              backgroundImage:
                                  (userData.profilePhoto != null &&
                                      userData.profilePhoto!.isNotEmpty)
                                  ? NetworkImage(userData.profilePhoto!)
                                  : null,
                              child:
                                  (userData.profilePhoto == null ||
                                      userData.profilePhoto!.isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: secondaryYellow,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            userData.name?.toUpperCase() ??
                                "NAMA TIDAK TERSEDIA",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit_note_rounded,
                            color: primaryBlue,
                          ),
                          onPressed: () =>
                              _showEditNameDialog(userData.name ?? ""),
                        ),
                      ],
                    ),
                    Text(
                      userData.email ?? "-",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle("Informasi Pelatihan"),
                    _buildInfoTile(
                      Icons.school_rounded,
                      "Program Pelatihan",
                      userData.training?.title ?? "-",
                    ),
                    _buildInfoTile(
                      Icons.layers_rounded,
                      "Angkatan / Batch",
                      "Batch ${userData.batch?.batchKe ?? '-'}",
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle("Data Pribadi"),
                    _buildInfoTile(
                      Icons.wc_rounded,
                      "Jenis Kelamin",
                      userData.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan',
                    ),
                    _buildInfoTile(
                      Icons.calendar_month_rounded,
                      "Periode",
                      "${userData.batch?.startDate ?? ''} - ${userData.batch?.endDate ?? ''}",
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text(
                          "KELUAR DARI AKUN",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
