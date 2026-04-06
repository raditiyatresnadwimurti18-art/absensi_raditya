import 'package:flutter/material.dart';
import 'package:absensi_raditya/api/controllers/auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  // Variabel penampung nilai yang dipilih (ID)
  String? selectedBatchId;
  String? selectedTrainingId;
  String? selectedGender;
  bool isLoading = false;

  final Color primaryBlue = const Color(0xFF005DA9);
  final Color secondaryYellow = const Color(0xFFFFCC00);

  // Data Batch sesuai JSON
  final List<Map<String, dynamic>> batchData = [
    {"id": 1, "batch_ke": "2"},
    {"id": 2, "batch_ke": "3"},
    {"id": 3, "batch_ke": "4"},
    {"id": 4, "batch_ke": "5"},
  ];

  // Data Pelatihan/Jurusan sesuai JSON
  final List<Map<String, dynamic>> trainingData = [
    {"id": 1, "title": "Data Management Staff (Operator Komputer)"},
    {"id": 2, "title": "Bahasa Inggris"},
    {"id": 3, "title": "Desainer Grafis Madya"},
    {"id": 4, "title": "Tata Boga"},
    {"id": 5, "title": "Tata Busana"},
    {"id": 6, "title": "Perhotelan"},
    {"id": 7, "title": "Teknisi Komputer"},
    {"id": 8, "title": "Teknisi Jaringan"},
    {"id": 9, "title": "Barista"},
    {"id": 10, "title": "Bahasa Korea"},
    {"id": 11, "title": "Make Up Artist"},
    {"id": 12, "title": "Desainer Multimedia"},
    {"id": 13, "title": "Content Creator"},
    {"id": 14, "title": "Web Programming"},
    {"id": 15, "title": "Digital Marketing"},
    {"id": 16, "title": "Mobile Programming"},
    {"id": 17, "title": "Akuntansi Junior"},
    {"id": 18, "title": "Konstruksi Bangunan dengan CAD"},
  ];

  void register() async {
    if (selectedGender == null ||
        selectedBatchId == null ||
        selectedTrainingId == null) {
      _showSnackBar("Harap lengkapi semua pilihan", Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthController.register(
        name: name.text,
        email: email.text,
        password: password.text,
        batchId: selectedBatchId!,
        trainingId: selectedTrainingId!,
        jenisKelamin: selectedGender!,
      );

      if (mounted) {
        Navigator.pop(context);
        _showSnackBar("Registrasi Berhasil!", Colors.green);
      }
    } catch (e) {
      _showSnackBar(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Daftar Akun"),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInput(name, "Nama Lengkap", Icons.person_outline),
            _buildInput(
              email,
              "Email",
              Icons.email_outlined,
              type: TextInputType.emailAddress,
            ),
            _buildInput(
              password,
              "Password",
              Icons.lock_outline,
              obscure: true,
            ),

            // Dropdown Batch
            _buildDropdown(
              label: "Pilih Batch",
              icon: Icons.calendar_today_outlined,
              value: selectedBatchId,
              items: batchData.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id'].toString(),
                  child: Text("Batch ${item['batch_ke']}"),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedBatchId = val),
            ),

            // Dropdown Jurusan
            _buildDropdown(
              label: "Pilih Jurusan",
              icon: Icons.school_outlined,
              value: selectedTrainingId,
              items: trainingData.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id'].toString(),
                  child: Text(item['title'], overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedTrainingId = val),
            ),

            // Dropdown Jenis Kelamin
            _buildDropdown(
              label: "Jenis Kelamin",
              icon: Icons.wc,
              value: selectedGender,
              items: ["Laki-laki", "Perempuan"]
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
              onChanged: (val) => setState(() => selectedGender = val),
            ),

            const SizedBox(height: 40),
            isLoading
                ? CircularProgressIndicator(color: primaryBlue)
                : ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryYellow,
                      foregroundColor: primaryBlue,
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "DAFTAR SEKARANG",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        isExpanded: true, // Agar teks panjang tidak overflow
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryBlue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryBlue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
