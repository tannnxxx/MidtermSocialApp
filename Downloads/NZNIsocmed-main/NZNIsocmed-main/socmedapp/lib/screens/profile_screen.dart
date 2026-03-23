import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  bool _isUploading = false;

  // --- FUNCTION: UPLOAD IMAGE ---
  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      User? user = _auth.currentUser;
      Uint8List bytes = await image.readAsBytes();
      Reference ref = _storage.ref().child('profiles/${user!.uid}.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      String downloadUrl = await ref.getDownloadURL();
      await user.updatePhotoURL(downloadUrl);
      await user.reload();
      setState(() {});
      _showSnackBar("Profile picture updated! ✨");
    } catch (e) {
      _showSnackBar("Upload failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // --- FUNCTION: EDIT NAME ---
  void _showEditNameDialog() {
    final nameController = TextEditingController(text: _auth.currentUser?.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(controller: nameController, decoration: const InputDecoration(hintText: "Enter full name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _auth.currentUser?.updateDisplayName(nameController.text.trim());
              await _auth.currentUser?.reload();
              Navigator.pop(context);
              setState(() {});
              _showSnackBar("Name updated!");
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- FUNCTION: CHANGE PASSWORD ---
  void _showChangePasswordDialog() {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: const InputDecoration(hintText: "Enter new password"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await _auth.currentUser?.updatePassword(passController.text.trim());
                Navigator.pop(context);
                _showSnackBar("Password changed successfully!");
              } catch (e) {
                _showSnackBar("Error: Re-login required for security", isError: true);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.blueAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("MY PROFILE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: _auth.currentUser?.reload(),
        builder: (context, snapshot) {
          User? user = _auth.currentUser;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // PHOTO SECTION
                  GestureDetector(
                    onTap: _isUploading ? null : _uploadImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage("${user!.photoURL!}?t=${DateTime.now().millisecondsSinceEpoch}")
                              : null,
                          child: (user?.photoURL == null && !_isUploading) ? const Icon(Icons.person, size: 80) : null,
                        ),
                        if (_isUploading) const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // NAME & EMAIL
                  Text((user?.displayName ?? "Traveler").toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  Text(user?.email ?? "", style: const TextStyle(color: Colors.blueGrey)),
                  const SizedBox(height: 40),

                  // BUTTONS SECTION
                  _buildOptionButton(onPressed: _showEditNameDialog, label: "EDIT NAME", icon: Icons.edit, color: Colors.blueAccent),
                  const SizedBox(height: 12),
                  _buildOptionButton(onPressed: _showChangePasswordDialog, label: "CHANGE PASSWORD", icon: Icons.lock_outline, color: Colors.orangeAccent),
                  const SizedBox(height: 12),
                  _buildOptionButton(onPressed: () => _auth.signOut(), label: "LOGOUT", icon: Icons.logout, color: Colors.redAccent, isOutlined: true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionButton({required VoidCallback onPressed, required String label, required IconData icon, required Color color, bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: isOutlined
          ? OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon, color: color), label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)), style: OutlinedButton.styleFrom(side: BorderSide(color: color), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))))
          : ElevatedButton.icon(onPressed: onPressed, icon: Icon(icon, color: Colors.white), label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))),
    );
  }
}