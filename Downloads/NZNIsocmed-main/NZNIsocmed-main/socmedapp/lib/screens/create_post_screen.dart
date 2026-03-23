import 'dart:typed_data'; // Para sa Image Bytes (Web Safe)
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  Uint8List? webImage; // Dito itatago ang bytes ng napiling picture
  bool _isSharing = false;

  final captionController = TextEditingController();
  final locationController = TextEditingController();

  // FUNCTION: PICK IMAGE
  // Pumipili ng image sa gallery at binabasa ito bilang 'Bytes' para hindi mag-error sa Web.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? selected = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (selected != null) {
      final bytes = await selected.readAsBytes();
      setState(() {
        webImage = bytes;
      });
    }
  }

  // FUNCTION: SHARE POST
  // Ito ang logic para i-upload ang image sa Storage at data sa Firestore.
  Future<void> _sharePost() async {
    if (webImage == null || captionController.text.isEmpty) return;

    setState(() => _isSharing = true); // Ipakita ang loading spinner

    try {
      final user = FirebaseAuth.instance.currentUser;
      final postId = DateTime.now().millisecondsSinceEpoch.toString();

      // 1. UPLOAD IMAGE SA STORAGE (Gamit ang putData para sa Web)
      Reference ref = FirebaseStorage.instance.ref().child('posts/$postId.jpg');
      await ref.putData(webImage!, SettableMetadata(contentType: 'image/jpeg'));
      String imageUrl = await ref.getDownloadURL();

      // 2. SAVE DATA SA FIRESTORE
      await FirebaseFirestore.instance.collection('posts').add({
        'caption': captionController.text.trim(),
        'location': locationController.text.trim(),
        'imageUrl': imageUrl,
        'userId': user?.uid,
        'userName': user?.displayName ?? "Traveler",
        'userImage': user?.photoURL ?? "",
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. REFRESH PROVIDER AT BALIK SA FEED
      if (mounted) {
        Provider.of<PostProvider>(context, listen: false).loadPosts();
        Navigator.pop(context);
      }
    } catch (e) {
      print("Upload Error: $e");
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CREATE POST"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // IMAGE DISPLAY AREA
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: webImage != null
                    ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(webImage!, fit: BoxFit.cover))
                    : const Icon(Icons.add_a_photo, size: 50, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            // CAPTION FIELD
            TextField(
              controller: captionController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: "Write a caption...", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 40),
            // SHARE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSharing ? null : _sharePost,
                child: _isSharing ? const CircularProgressIndicator() : const Text("SHARE POST"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}