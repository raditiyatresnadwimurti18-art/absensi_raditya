import 'package:absensi_raditya/api/controllers/auth.dart';
import 'package:absensi_raditya/api/controllers/profile_controller.dart';
import 'package:absensi_raditya/page/navigator_page/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:absensi_raditya/page/login/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final email = TextEditingController();
  final password = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;

  // Tema Warna Berdasarkan Logo
  final Color primaryBlue = const Color(0xFF005DA9);
  final Color secondaryYellow = const Color(0xFFFFCC00);
  final Color lightBg = const Color(0xFFF8FAFC);

  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideIn = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      _showSnackBar("Email dan Password wajib diisi", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthController.login(
        email: email.text.trim(),
        password: password.text,
      );

      if (result != null && mounted) {
        try {
          await ProfileController.getProfile();
        } catch (profileError) {
          debugPrint("Gagal sinkronisasi data profil: $profileError");
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          e.toString().replaceAll("Exception: ", ""),
          Colors.redAccent,
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
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
      body: Stack(
        children: [
          // Lingkaran Dekorasi Background
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: primaryBlue.withOpacity(0.05),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideIn,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogoSection(),
                        const SizedBox(height: 50),
                        _buildInputFields(),
                        const SizedBox(height: 30),
                        _buildLoginButton(),
                        const SizedBox(height: 30),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Hero(
          tag: 'logo',
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/logo.png',
              height: 100,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.account_circle, size: 100, color: primaryBlue),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "SELAMAT DATANG",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: primaryBlue,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Absensi Digital - Solusi Kerja Pintar",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        // Field Email
        _buildTextField(
          controller: email,
          label: "Email",
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          // Tambahkan ini agar saat tekan 'next' di keyboard email, kursor pindah atau submit
          onSubmitted: (value) => FocusScope.of(context).nextFocus(),
        ),
        const SizedBox(height: 20),
        // Field Password
        _buildTextField(
          controller: password,
          label: "Password",
          icon: Icons.lock_rounded,
          isPassword: true,
          obscureText: obscurePassword,
          onTogglePassword: () =>
              setState(() => obscurePassword = !obscurePassword),
          // PERBAIKAN DI SINI: Gunakan fungsi anonim (value) => login()
          onSubmitted: (value) => login(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    Function(String)? onSubmitted,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: primaryBlue, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.grey[400],
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
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
          onPressed: isLoading ? null : login,
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
                  "MASUK SEKARANG",
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

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Belum punya akun? ", style: TextStyle(color: Colors.grey[600])),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          ),
          child: Text(
            "Daftar di sini",
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
