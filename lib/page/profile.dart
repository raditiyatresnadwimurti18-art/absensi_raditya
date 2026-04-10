import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  // PALET WARNA SESUAI LOGO
  final Color primaryBlue = const Color(0xFF0074B7);
  final Color primaryYellow = const Color(0xFFFFD700);
  final Color bgColor = const Color(0xFFF1F5F9);

  bool _isLoading = false;
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  void _loadLocalData() {
    setState(() {
      _userFuture = AuthPreferences.getUserData();
    });
  }

  Future<void> _refreshData() async {
    try {
      await ProfileController.getProfile();
      if (mounted) {
        _loadLocalData();
      }
    } catch (e) {
      debugPrint("Gagal sinkronisasi data: $e");
    }
  }

  // --- LOGIKA UPDATE FOTO (Tetap Sama) ---
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

        await ProfileController.editFoto(
          base64String: base64Image,
          name: currentName,
        );

        await _refreshData();

        _showSuccessSnackBar("Foto profil diperbarui!");
      } catch (e) {
        _showErrorSnackBar("Gagal memperbarui foto: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // --- LOGIKA EDIT NAMA (UI Dipercantik) ---
  void _showEditNameDialog(String currentName, String currentEmail) {
    TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Ubah Nama Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: "Nama Lengkap",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
                  await _refreshData();
                  _showSuccessSnackBar("Nama berhasil diperbarui!");
                } catch (e) {
                  _showErrorSnackBar("Gagal memperbarui nama: $e");
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Konfirmasi Logout"),
        content: const Text("Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("TIDAK", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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

  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // --- UI SECTION ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Header Gradasi & Lingkaran Dekoratif
          _buildHeaderBackground(),

          FutureBuilder<Map<String, dynamic>?>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !_isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text("Data tidak tersedia."));
              }

              final userData = Data.fromJson(snapshot.data!);

              return RefreshIndicator(
                onRefresh: _refreshData,
                child: CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildProfileHeader(userData),
                            const SizedBox(height: 32),
                            _buildSectionTitle("Informasi Pelatihan"),
                            _buildInfoTile(
                              Icons.school_rounded,
                              "Program",
                              userData.training?.title ?? "-",
                            ),
                            _buildInfoTile(
                              Icons.layers_rounded,
                              "Batch",
                              "Angkatan ${userData.batch?.batchKe ?? '-'}",
                            ),
                            const SizedBox(height: 16),
                            _buildSectionTitle("Data Pribadi"),
                            _buildInfoTile(
                              Icons.wc_rounded,
                              "Kelamin",
                              userData.jenisKelamin == 'L'
                                  ? 'Laki-laki'
                                  : 'Perempuan',
                            ),
                            _buildInfoTile(
                              Icons.date_range_rounded,
                              "Masa Aktif",
                              userData.batch?.startDate != null
                                  ? "${DateFormat('dd MMM yyyy').format(userData.batch!.startDate!)} - ${DateFormat('dd MMM yyyy').format(userData.batch!.endDate!)}"
                                  : "-",
                            ),
                            const SizedBox(height: 40),
                            _buildLogoutButton(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return const SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        "PENGATURAN PROFIL",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          fontSize: 16,
        ),
      ),
      centerTitle: true,
      floating: true,
    );
  }

  Widget _buildProfileHeader(Data userData) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Lingkaran Dekoratif Kuning (Mirip Logo)
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryYellow.withOpacity(0.3),
                  width: 8,
                ),
              ),
            ),
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
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
                    ? Icon(Icons.person, size: 70, color: primaryBlue)
                    : null,
              ),
            ),
            // Tombol Kamera
            Positioned(
              bottom: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => _pickAndUploadImage(userData.name ?? ""),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryYellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userData.name?.toUpperCase() ?? "USER",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showEditNameDialog(
                userData.name ?? "",
                userData.email ?? "",
              ),
              child: Icon(Icons.edit_attributes, color: primaryBlue, size: 22),
            ),
          ],
        ),
        Text(
          userData.email ?? "-",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: primaryYellow,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
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
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          "KELUAR DARI AKUN",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: CircularProgressIndicator(color: primaryBlue),
        ),
      ),
    );
  }
}
