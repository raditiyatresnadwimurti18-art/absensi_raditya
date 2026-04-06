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
  final batchId = TextEditingController();
  final trainingId = TextEditingController();

  String? selectedGender;

  void register() async {
    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih jenis kelamin terlebih dahulu")),
      );
      return;
    }

    try {
      await AuthController.register(
        name: name.text,
        email: email.text,
        password: password.text,
        batchId: batchId.text,
        trainingId: trainingId.text,
        jenisKelamin: selectedGender!,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Registrasi Berhasil!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: email,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: batchId,
              decoration: const InputDecoration(
                labelText: "ID Batch",
                hintText: "Contoh: 1",
                prefixIcon: Icon(Icons.group),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: trainingId,
              decoration: const InputDecoration(
                labelText: "ID Jurusan",
                hintText: "Contoh: 2",
                prefixIcon: Icon(Icons.school),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Jenis Kelamin",
                prefixIcon: Icon(Icons.wc),
              ),
              value: selectedGender,
              items: ["Laki-laki", "Perempuan"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedGender = val;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: register,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Daftar Sekarang"),
            ),
          ],
        ),
      ),
    );
  }
}
