import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:absensi_raditya/api/preferences.dart';
import 'package:absensi_raditya/models/profile_model.dart';
import 'package:absensi_raditya/api/controllers/profile_controller.dart';
import 'package:absensi_raditya/page/auth/login.dart';
import 'package:absensi_raditya/theme/app_theme.dart';
import 'package:absensi_raditya/widgets/profile/profile_header.dart';
import 'package:absensi_raditya/widgets/profile/profile_info_tile.dart';
import 'package:absensi_raditya/widgets/profile/profile_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  late Future<Map<String, dynamic>?> _userFuture;

  // ─── Lifecycle ──────────────────────────────────────────────────

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
      if (mounted) _loadLocalData();
    } catch (e) {
      debugPrint("Gagal sinkronisasi data: $e");
    }
  }

  // ─── Logika Aksi ────────────────────────────────────────────────

  Future<void> _pickAndUploadImage(String currentName) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
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

  void _showEditNameDialog(String currentName, String currentEmail) {
    final nameController = TextEditingController(text: currentName);
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: appColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Ubah Nama Profil",
          style: TextStyle(fontWeight: FontWeight.bold, color: appColors.text),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: appColors.text),
          decoration: InputDecoration(
            labelText: "Nama Lengkap",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
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
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
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

  // ─── Helper ─────────────────────────────────────────────────────

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

  // ─── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.background,
      body: Stack(
        children: [
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
                            ProfileHeader(
                              userData: userData,
                              onCameraTap: () =>
                                  _pickAndUploadImage(userData.name ?? ""),
                              onEditNameTap: () => _showEditNameDialog(
                                userData.name ?? "",
                                userData.email ?? "",
                              ),
                            ),
                            const SizedBox(height: 32),
                            const ProfileSectionTitle(
                              title: "Informasi Pelatihan",
                            ),
                            ProfileInfoTile(
                              icon: Icons.school_rounded,
                              label: "Program",
                              value: userData.training?.title ?? "-",
                            ),
                            ProfileInfoTile(
                              icon: Icons.layers_rounded,
                              label: "Batch",
                              value:
                                  "Angkatan ${userData.batch?.batchKe ?? '-'}",
                            ),
                            const SizedBox(height: 16),
                            const ProfileSectionTitle(title: "Data Pribadi"),
                            ProfileInfoTile(
                              icon: Icons.wc_rounded,
                              label: "Kelamin",
                              value: userData.jenisKelamin == 'L'
                                  ? 'Laki-laki'
                                  : 'Perempuan',
                            ),
                            ProfileInfoTile(
                              icon: Icons.date_range_rounded,
                              label: "Masa Aktif",
                              value: userData.batch?.startDate != null
                                  ? "${DateFormat('dd MMM yyyy').format(userData.batch!.startDate!)} - ${DateFormat('dd MMM yyyy').format(userData.batch!.endDate!)}"
                                  : "-",
                            ),
                            const SizedBox(height: 40),
                            ProfileLogoutButton(
                              onPressed: () => _showLogoutDialog(context),
                            ),
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
          if (_isLoading) const ProfileLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      height: 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, Color(0xFF005A8E)],
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
}
