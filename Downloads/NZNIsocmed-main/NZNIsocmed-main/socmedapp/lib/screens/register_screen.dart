import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart'; // Siguraduhing tama ang import path ng Login Screen mo

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- CONTROLLERS ---
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  String? selectedGender;
  bool loading = false;

  // --- FUNCTION: REGISTER LOGIC ---
  void register() async {
    if (firstName.text.isEmpty || lastName.text.isEmpty || email.text.isEmpty ||
        password.text.isEmpty || selectedGender == null) {
      _showMsg("Please fill all fields and select gender", isError: true);
      return;
    }

    if (password.text != confirmPassword.text) {
      _showMsg("Passwords do not match", isError: true);
      return;
    }

    setState(() => loading = true);

    try {
      String fullName = "${firstName.text.trim()} ${lastName.text.trim()}";

      // Tawagin ang AuthService para sa registration
      await AuthService().registerUser(
        email.text.trim(),
        password.text.trim(),
        fullName,
      );

      if (mounted) {
        _showMsg("Account created! Please Login");
        _goToLogin(); // Awtomatikong babalik sa Login pagkatapos
      }
    } catch (e) {
      if (mounted) _showMsg("Registration failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // --- NAVIGATION FUNCTION ---
  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // --- SNACKBAR HELPER ---
  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: Stack(
        children: [
          // 1. DECORATIVE BACKGROUND BLOBS
          Positioned(top: -100, right: -50, child: _buildBlurBlob(color: const Color(0xFF64B5F6).withOpacity(0.4), size: 350)),
          Positioned(bottom: -80, left: -80, child: _buildBlurBlob(color: const Color(0xFFFFB74D).withOpacity(0.3), size: 300)),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(color: Colors.transparent),
          ),

          // 2. BACK BUTTON (TOP LEFT)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A237E), size: 28),
                onPressed: _goToLogin, // Babalik sa Login
              ),
            ),
          ),

          // 3. REGISTRATION FORM
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        "Register your account",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))
                    ),
                    const SizedBox(height: 25),

                    // NAMES
                    Row(
                      children: [
                        Expanded(child: _buildTextField(controller: firstName, label: "First Name", icon: Icons.person_outline)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildTextField(controller: lastName, label: "Last Name", icon: Icons.person_outline)),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // GENDER
                    _buildGenderSelector(),
                    const SizedBox(height: 15),

                    // EMAIL & PASSWORDS
                    _buildTextField(controller: email, label: "Email Address", icon: Icons.email_outlined),
                    const SizedBox(height: 15),
                    _buildTextField(controller: password, label: "Password", icon: Icons.lock_outline_rounded, isPassword: true),
                    const SizedBox(height: 15),
                    _buildTextField(controller: confirmPassword, label: "Confirm Password", icon: Icons.lock_reset_rounded, isPassword: true),

                    const SizedBox(height: 30),

                    // CREATE BUTTON
                    loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: const Text("CREATE ACCOUNT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LOGIN LINK (Idinagdag)
                    GestureDetector(
                      onTap: _goToLogin,
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                          children: [
                            TextSpan(
                              text: "Login here",
                              style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildGenderSelector() {
    return Row(
      children: [
        _genderOption("Male", Icons.male_rounded),
        const SizedBox(width: 10),
        _genderOption("Female", Icons.female_rounded),
      ],
    );
  }

  Widget _genderOption(String label, IconData icon) {
    bool isSelected = selectedGender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedGender = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E88E5) : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.blueGrey, size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.blueGrey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1E88E5), size: 22),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildBlurBlob({required Color color, required double size}) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}