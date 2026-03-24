import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import '../providers/post_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final captionController = TextEditingController();
  final locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedFile;
  bool isVideo = false;
  VideoPlayerController? _videoController;

  Future<void> _pickMedia(bool video) async {
    XFile? file = video
        ? await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 5))
        : await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (file != null) {
      if (_videoController != null) await _videoController!.dispose();
      setState(() {
        _pickedFile = file;
        isVideo = video;
      });
      if (video) {
        _videoController = kIsWeb
            ? VideoPlayerController.network(file.path)
            : VideoPlayerController.file(File(file.path));
        _videoController!.initialize().then((_) {
          setState(() {});
          _videoController!.play();
          _videoController!.setLooping(true);
        });
      }
    }
  }

  @override
  void dispose() {
    captionController.dispose();
    locationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0F7FF),
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // INALIS ANG ROW NA MAY CLOSE BUTTON DITO
                  const SizedBox(height: 20),
                  Text(
                      "CREATE NEW POST",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: isDark ? Colors.white : Colors.black
                      )
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () => _showPicker(isDark),
                    child: Container(
                      height: 250, width: double.infinity,
                      decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3))
                      ),
                      child: _pickedFile == null
                          ? const Icon(Icons.add_a_photo, size: 50, color: Colors.blue)
                          : ClipRRect(borderRadius: BorderRadius.circular(20), child: _buildPreview()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInput(captionController, "What's on your mind?", Icons.notes, isDark, lines: 3),
                  const SizedBox(height: 15),
                  _buildInput(locationController, "Add location...", Icons.location_on, isDark),
                  const SizedBox(height: 30),
                  provider.isLoading ? const CircularProgressIndicator() : _buildPostBtn(provider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (isVideo && _videoController != null) return VideoPlayer(_videoController!);
    return kIsWeb
        ? Image.network(_pickedFile!.path, fit: BoxFit.cover)
        : Image.file(File(_pickedFile!.path), fit: BoxFit.cover);
  }

  void _showPicker(bool isDark) {
    showModalBottomSheet(
        context: context,
        backgroundColor: isDark ? Colors.black : Colors.white,
        builder: (ctx) => Wrap(children: [
          ListTile(
              leading: const Icon(Icons.image),
              title: Text("Photo", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () { _pickMedia(false); Navigator.pop(context); }
          ),
          ListTile(
              leading: const Icon(Icons.video_library),
              title: Text("Video (Max 5s)", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () { _pickMedia(true); Navigator.pop(context); }
          ),
        ])
    );
  }

  Widget _buildInput(TextEditingController c, String h, IconData i, bool d, {int lines = 1}) {
    return TextField(
        controller: c,
        maxLines: lines,
        style: TextStyle(color: d ? Colors.white : Colors.black),
        decoration: InputDecoration(
            hintText: h,
            hintStyle: TextStyle(color: d ? Colors.white54 : Colors.black54),
            prefixIcon: Icon(i, color: Colors.blue),
            filled: true,
            fillColor: d ? Colors.white10 : Colors.white.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
        )
    );
  }

  Widget _buildPostBtn(PostProvider p) {
    return SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),
            onPressed: () async {
              if (_pickedFile == null || captionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select media and add a caption."))
                );
                return;
              }
              try {
                await p.addPost(
                    file: _pickedFile!,
                    caption: captionController.text,
                    location: locationController.text,
                    userName: FirebaseAuth.instance.currentUser?.displayName ?? "Traveler",
                    isVideo: isVideo
                );
                // Optional: Linisin ang fields pagkatapos mag-post
                captionController.clear();
                locationController.clear();
                setState(() { _pickedFile = null; });

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Posted successfully!"))
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error: File too large or connection issue."))
                );
              }
            },
            child: const Text("POST NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        )
    );
  }

  Widget _buildBackground(bool d) => Stack(children: [
    Positioned(
        top: -50,
        right: -50,
        child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(color: Colors.blue.withOpacity(d ? 0.1 : 0.2), shape: BoxShape.circle)
        )
    ),
    BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container(color: Colors.transparent))
  ]);
}