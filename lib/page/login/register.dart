import 'package:flutter/material.dart';
import 'package:absensi_raditya/api/controllers/auth.dart';

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

  String? selectedBatchId;
  String? selectedTrainingId;
  String? selectedGender;
  bool isLoading = false;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  // --- LOGIKA REGISTER (Tetap) ---
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
        _showSnackBar("Registrasi Berhasil! Silakan Login", Colors.green);
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

  // --- UI DESIGN ---
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
      body: FadeTransition(
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
                    items: batchData
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item['id'].toString(),
                            child: Text("Batch ${item['batch_ke']}"),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedBatchId = val),
                  ),

                  _buildDropdown(
                    label: "Jurusan",
                    icon: Icons.school_outlined,
                    value: selectedTrainingId,
                    items: trainingData
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item['id'].toString(),
                            child: Text(
                              item['title'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedTrainingId = val),
                  ),

                  _buildDropdown(
                    label: "Jenis Kelamin",
                    icon: Icons.wc_rounded,
                    value: selectedGender,
                    items: ["Laki-laki", "Perempuan"]
                        .map(
                          (val) =>
                              DropdownMenuItem(value: val, child: Text(val)),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedGender = val),
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
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        icon: Icon(
          Icons.arrow_drop_down_circle_outlined,
          color: primaryBlue.withOpacity(0.5),
        ),
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

  // DATA BATCH & TRAINING (Tetap)
  final List<Map<String, dynamic>> batchData = [
    {"id": 1, "batch_ke": "2"},
    {"id": 2, "batch_ke": "3"},
    {"id": 3, "batch_ke": "4"},
    {"id": 4, "batch_ke": "5"},
  ];

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
}
