import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/post_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  File? _imageFile;
  String? _webImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _loadProfilePic();
  }

  Future<void> _loadProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    final String? path = prefs.getString('profile_pic_path');
    if (path != null && File(path).existsSync()) {
      setState(() => _imageFile = File(path));
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        setState(() => _webImage = pickedFile.path);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_pic_path', pickedFile.path);
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

  // FUNCTION PARA SA CHANGE PASSWORD DIALOG
  void _showChangePasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(hintText: "Enter new password"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await _auth.currentUser?.updatePassword(controller.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password updated successfully!")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")));
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isDark = Provider.of<PostProvider>(context).isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0F7FF),
      body: Stack(
        children: [
          // Background Decorations
          _buildBlob(Colors.blue.withOpacity(0.15), 300, top: -50, right: -50),
          _buildBlob(Colors.purple.withOpacity(0.1), 200, bottom: 100, left: -50),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Text("MY PROFILE",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: textColor)),
                const SizedBox(height: 40),

                // Modern Profile Image Section
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple.withOpacity(0.5)],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                          backgroundImage: kIsWeb
                              ? (_webImage != null ? NetworkImage(_webImage!) : null)
                              : (_imageFile != null ? FileImage(_imageFile!) : null),
                          child: (kIsWeb ? _webImage == null : _imageFile == null)
                              ? Icon(Icons.person, size: 80, color: textColor.withOpacity(0.3))
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: const CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            radius: 20,
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Text(user?.displayName ?? "Traveler",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textColor)),
                Text(user?.email ?? "no-email@nzni.com",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16)),

                const SizedBox(height: 40),

                // ACTIONS CARD
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          )
                      ],
                    ),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildSettingTile(
                          icon: Icons.dark_mode_rounded,
                          title: "Dark Mode",
                          isDark: isDark,
                          trailing: Switch(
                            value: isDark,
                            onChanged: (v) => Provider.of<PostProvider>(context, listen: false).toggleTheme(),
                            activeColor: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildSettingTile(
                          icon: Icons.lock_reset_rounded,
                          title: "Change Password",
                          isDark: isDark,
                          onTap: _showChangePasswordDialog,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          child: Divider(thickness: 0.5),
                        ),
                        _buildSettingTile(
                          icon: Icons.logout_rounded,
                          title: "Logout",
                          isDark: isDark,
                          color: Colors.redAccent,
                          onTap: () => _auth.signOut(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required bool isDark,
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: isDark ? Colors.white.withOpacity(0.03) : Colors.grey[50],
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (color ?? Colors.blueAccent).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color ?? Colors.blueAccent, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: color ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.black26),
      ),
    );
  }

  Widget _buildBlob(Color c, double s, {double? top, double? right, double? bottom, double? left}) =>
      Positioned(top: top, right: right, bottom: bottom, left: left, child: Container(width: s, height: s, decoration: BoxDecoration(color: c, shape: BoxShape.circle)));
}