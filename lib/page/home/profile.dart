import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Pastikan import ini sesuai dengan struktur folder projectmu
import 'package:absensi_raditya/api/preferences.dart';
import 'package:absensi_raditya/models/profile_model.dart';
import 'package:absensi_raditya/api/controllers/profile_controller.dart';
import 'package:absensi_raditya/page/login/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color primaryBlue = const Color(0xFF005DA9);
  final Color secondaryYellow = const Color(0xFFFFCC00);

  bool _isLoading = false;
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  // Memuat data dari lokal (SharedPreferences)
  void _loadLocalData() {
    setState(() {
      _userFuture = AuthPreferences.getUserData();
    });
  }

  // Fungsi krusial: Ambil data terbaru dari server -> Simpan ke Lokal -> Update UI
  Future<void> _refreshData() async {
    try {
      // getProfile() di dalam controller harus sudah memanggil AuthPreferences.saveUserData
      await ProfileController.getProfile();
      if (mounted) {
        _loadLocalData();
      }
    } catch (e) {
      debugPrint("Gagal sinkronisasi data: $e");
    }
  }

  // --- LOGIKA UPDATE FOTO ---
  Future<void> _pickAndUploadImage(String currentName) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      final messenger = ScaffoldMessenger.of(context);
      setState(() => _isLoading = true);

      try {
        File file = File(pickedFile.path);
        String base64Image = base64Encode(await file.readAsBytes());

        // 1. Upload ke API
        await ProfileController.editFoto(
          base64String: base64Image,
          name: currentName,
        );

        // 2. Paksa ambil data terbaru dari server agar lokal terupdate
        await _refreshData();

        messenger.showSnackBar(
          const SnackBar(
            content: Text("Foto profil berhasil diperbarui!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text("Gagal memperbarui foto: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // --- LOGIKA EDIT NAMA ---
  void _showEditNameDialog(String currentName, String currentEmail) {
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
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(dialogContext);

                setState(() => _isLoading = true);
                try {
                  await ProfileController.updateProfile(
                    name: nameController.text.trim(),
                    email: currentEmail,
                  );

                  // Sinkronisasi data setelah update nama
                  await _refreshData();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("Nama berhasil diperbarui!"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text("Gagal memperbarui nama: $e"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
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
              if (context.mounted) {
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
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !_isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Data profil tidak ditemukan."),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _refreshData,
                        child: const Text("Refresh"),
                      ),
                    ],
                  ),
                );
              }

              final userData = Data.fromJson(snapshot.data!);

              return RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // --- FOTO PROFIL SECTION ---
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
                                    (userData.profilePhotoUrl != null &&
                                        userData.profilePhotoUrl!.isNotEmpty)
                                    ? NetworkImage(
                                        "${userData.profilePhotoUrl}?t=${DateTime.now().millisecondsSinceEpoch}",
                                      )
                                    : null,
                                child:
                                    (userData.profilePhotoUrl == null ||
                                        userData.profilePhotoUrl!.isEmpty)
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
                                onTap: () =>
                                    _pickAndUploadImage(userData.name ?? ""),
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

                      // --- NAMA & EMAIL SECTION ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              userData.name?.toUpperCase() ?? "PENGGUNA",
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
                            onPressed: () => _showEditNameDialog(
                              userData.name ?? "",
                              userData.email ?? "",
                            ),
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

                      // --- DETAIL INFORMASI SECTION ---
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
                        userData.jenisKelamin == 'L'
                            ? 'Laki-laki'
                            : 'Perempuan',
                      ),
                      _buildInfoTile(
                        Icons.calendar_month_rounded,
                        "Periode Pelatihan",
                        userData.batch?.startDate != null
                            ? "${DateFormat('dd/MM/yyyy').format(userData.batch!.startDate!)} - ${DateFormat('dd/MM/yyyy').format(userData.batch!.endDate!)}"
                            : "-",
                      ),

                      const SizedBox(height: 40),

                      // --- TOMBOL LOGOUT ---
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
                ),
              );
            },
          ),
          // LOADING OVERLAY
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
