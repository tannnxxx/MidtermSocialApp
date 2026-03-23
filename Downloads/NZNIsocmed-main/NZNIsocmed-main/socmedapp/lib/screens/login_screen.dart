import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  // --- FUNCTION: LOGIN LOGIC ---
  void login() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      _showMsg("Please fill all fields", isError: true);
      return;
    }

    setState(() => loading = true);

    try {
      // Tinatawag ang AuthService para sa authentication
      await AuthService().loginUser(
        email.text.trim(),
        password.text.trim(),
      );

      if (mounted) {
        // Kapag successful, dideretso sa HomeScreen at tatanggalin ang Login sa stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showMsg("Wrong email or password. Please try again.", isError: true);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // Helper para sa SnackBar notifications
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
      backgroundColor: const Color(0xFFF0F4F8),
      body: Stack(
        children: [
          // 1. BACKGROUND DECORATION (BLOBS)
          Positioned(top: -50, right: -50, child: _buildBlurBlob(color: Colors.blue.withOpacity(0.4), size: 300)),
          Positioned(bottom: 100, left: -80, child: _buildBlurBlob(color: Colors.orange.withOpacity(0.3), size: 250)),
          Positioned(top: 200, left: 50, child: _buildBlurBlob(color: Colors.teal.withOpacity(0.2), size: 200)),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),

          // 2. LOGIN FORM
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.explore_rounded, size: 65, color: Color(0xFF1E88E5)),
                    const SizedBox(height: 10),
                    const Text(
                      "TRAVEL SOCIAL",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Color(0xFF263238),
                      ),
                    ),
                    const Text("Discover your next journey", style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
                    const SizedBox(height: 35),

                    // TEXT FIELDS
                    _buildTextField(controller: email, label: "Email Address", icon: Icons.email_outlined),
                    const SizedBox(height: 15),
                    _buildTextField(controller: password, label: "Password", icon: Icons.lock_outline_rounded, isPassword: true),

                    const SizedBox(height: 25),

                    // LOGIN BUTTON
                    loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LINK TO REGISTER
                    GestureDetector(
                      onTap: () {
                        // Gamit ang push para pwedeng mag-back kung gusto ng user
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen())
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "New here? ",
                          style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                          children: [
                            TextSpan(
                              text: "Create Account",
                              style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF1E88E5), size: 22),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildBlurBlob({required Color color, required double size}) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}