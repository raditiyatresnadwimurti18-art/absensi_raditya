import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:absensi_raditya/api/api_service.dart';
import 'package:absensi_raditya/api/controllers/auth.dart';
import 'package:absensi_raditya/models/batch_model.dart';
import 'package:absensi_raditya/models/training_model.dart';
import 'package:absensi_raditya/navigator_page/main_navigation.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  List<BatchModel> listBatches = [];
  List<TrainingModel> filteredTrainings = [];

  String? selectedBatchId;
  String? selectedTrainingId;
  String? selectedGender;
  bool isLoading = false;
  bool isDataLoading = true;

  final Color primaryBlue = const Color(0xFF005DA9);
  final Color secondaryYellow = const Color(0xFFFFCC00);
  final Color lightBg = const Color(0xFFF8FAFC);

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    fetchInitialData();
  }

  void fetchInitialData() async {
    try {
      final response = await ApiService.getBatches();
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final dynamic data = responseData['data'];

        if (data != null && data is List) {
          setState(() {
            listBatches = data.map((e) => BatchModel.fromJson(e)).toList();
            isDataLoading = false;
          });
        } else {
          _showSnackBar("Format data tidak sesuai", Colors.orange);
          setState(() => isDataLoading = false);
        }
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        _showSnackBar(
            errorData['message'] ?? "Gagal mengambil data pelatihan", Colors.red);
        setState(() => isDataLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      _showSnackBar("Terjadi kesalahan: $e", Colors.red);
      setState(() => isDataLoading = false);
    }
  }

  void onBatchChanged(String? val) {
    setState(() {
      selectedBatchId = val;
      selectedTrainingId = null; // Reset jurusan saat batch berubah

      if (val != null && listBatches.isNotEmpty) {
        // Cari batch yang dipilih dari list secara aman
        try {
          final batch = listBatches.firstWhere((b) => b.id.toString() == val);
          filteredTrainings = batch.trainings;
        } catch (e) {
          filteredTrainings = [];
        }
      } else {
        filteredTrainings = [];
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void register() async {
    if (name.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty ||
        selectedGender == null ||
        selectedBatchId == null ||
        selectedTrainingId == null) {
      _showSnackBar("Harap lengkapi semua data", Colors.orange);
      return;
    }

    setState(() => isLoading = true);
    try {
      final result = await AuthController.register(
        name: name.text,
        email: email.text,
        password: password.text,
        batchId: selectedBatchId!,
        trainingId: selectedTrainingId!,
        jenisKelamin: selectedGender!,
      );

      if (mounted && result != null) {
        // Karena AuthController.register sudah menyimpan data login,
        // kita bisa langsung arahkan ke halaman utama atau minta login ulang.
        // Jika ingin otomatis login:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
        );
        _showSnackBar("Registrasi Berhasil! Selamat Datang", Colors.green);
      }
    } catch (e) {
      _showSnackBar(
        e.toString().replaceAll("Exception: ", ""),
        Colors.redAccent,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        title: const Text(
          "Buat Akun Baru",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: lightBg,
        foregroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: isDataLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : FadeTransition(
              opacity: _fadeIn,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildHeaderIcon(),
                    const SizedBox(height: 30),

                    // Form Inputs
                    _buildCardWrapper(
                      children: [
                        _buildInput(
                          name,
                          "Nama Lengkap",
                          Icons.person_outline_rounded,
                        ),
                        _buildInput(
                          email,
                          "Email",
                          Icons.email_outlined,
                          type: TextInputType.emailAddress,
                        ),
                        _buildInput(
                          password,
                          "Password",
                          Icons.lock_outline_rounded,
                          obscure: true,
                        ),

                        _buildDropdown(
                          label: "Batch",
                          icon: Icons.calendar_today_rounded,
                          value: selectedBatchId,
                          items: listBatches
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item.id.toString(),
                                  child: Text("Batch ${item.batchKe}"),
                                ),
                              )
                              .toList(),
                          onChanged: onBatchChanged,
                        ),

                        _buildDropdown(
                          label: selectedBatchId == null
                              ? "Pilih Batch Dahulu"
                              : "Jurusan",
                          icon: Icons.school_outlined,
                          value: selectedTrainingId,
                          items: filteredTrainings
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item.id.toString(),
                                  child: Text(
                                    item.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: selectedBatchId == null
                              ? null
                              : (val) =>
                                  setState(() => selectedTrainingId = val),
                        ),

                        _buildDropdown(
                          label: "Jenis Kelamin",
                          icon: Icons.wc_rounded,
                          value: selectedGender,
                          items: ["Laki-laki", "Perempuan"]
                              .map(
                                (val) => DropdownMenuItem(
                                    value: val, child: Text(val)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedGender = val),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    _buildRegisterButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderIcon() {
    return Hero(
      tag: 'logo',
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(Icons.person_add_rounded, size: 40, color: primaryBlue),
      ),
    );
  }

  Widget _buildCardWrapper({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRegisterButton() {
    return AnimatedScale(
      scale: isLoading ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: secondaryYellow.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : register,
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryYellow,
            foregroundColor: primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? CircularProgressIndicator(color: primaryBlue, strokeWidth: 3)
              : const Text(
                  "DAFTAR SEKARANG",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        disabledHint: Text(label),
        icon: Icon(
          Icons.arrow_drop_down_circle_outlined,
          color: primaryBlue.withOpacity(onChanged == null ? 0.2 : 0.5),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(icon,
              color: onChanged == null ? Colors.grey : primaryBlue, size: 22),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryBlue, width: 2),
          ),
        ),
        value: value,
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(icon, color: primaryBlue, size: 22),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryBlue, width: 2),
          ),
        ),
      ),
    );
  }
}
