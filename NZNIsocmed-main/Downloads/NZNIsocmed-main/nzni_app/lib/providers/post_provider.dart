import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isLoading = false;

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // --- UPLOAD POST (PHOTO/VIDEO) ---
  Future<void> addPost({
    required XFile file,
    required String caption,
    required String location,
    required String userName,
    required bool isVideo,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      Uint8List fileBytes = await file.readAsBytes();
      String base64Media = base64Encode(fileBytes);

      await FirebaseFirestore.instance.collection('posts').add({
        'url': base64Media,
        'caption': caption,
        'location': location.isEmpty ? "Unknown" : location,
        'userName': userName,
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'type': isVideo ? 'video' : 'photo',
        'likes': 0,
        'likedBy': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- LIKES LOGIC ---
  Future<void> toggleLike(String postId, List likedBy) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final docRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    if (likedBy.contains(uid)) {
      await docRef.update({
        'likedBy': FieldValue.arrayRemove([uid]),
        'likes': FieldValue.increment(-1)
      });
    } else {
      await docRef.update({
        'likedBy': FieldValue.arrayUnion([uid]),
        'likes': FieldValue.increment(1)
      });
    }
  }

  // --- COMMENTS LOGIC ---
  Future<void> addComment(String postId, String text) async {
    if (text.trim().isEmpty) return;
    await FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').add({
      'text': text,
      'userName': FirebaseAuth.instance.currentUser?.displayName ?? "Traveler",
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- DELETE LOGIC ---
  Future<void> deletePost(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  // --- 10 INTERNATIONAL TRAVEL SAMPLES ---
  Future<void> seedExamplePosts() async {
    _isLoading = true;
    notifyListeners();

    List<Map<String, dynamic>> examples = [
      {'loc': 'Paris, France', 'cap': 'Eiffel Tower at sunset. 🗼', 'url': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800'},
      {'loc': 'Tokyo, Japan', 'cap': 'Shibuya Crossing lights. 🇯🇵', 'url': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800'},
      {'loc': 'Bali, Indonesia', 'cap': 'Paradise found. 🌴', 'url': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800'},
      {'loc': 'New York, USA', 'cap': 'Central Park views. 🗽', 'url': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800'},
      {'loc': 'Santorini, Greece', 'cap': 'Blue domes and white walls. 🇬🇷', 'url': 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800'},
      {'loc': 'Seoul, South Korea', 'cap': 'Traditional vibes. 🇰🇷', 'url': 'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=800'},
      {'loc': 'Rome, Italy', 'cap': 'The Colosseum. 🏛️', 'url': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800'},
      {'loc': 'London, UK', 'cap': 'Tower Bridge morning. 🇬🇧', 'url': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800'},
      {'loc': 'Sydney, Australia', 'cap': 'Opera House. 🇦🇺', 'url': 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=800'},
      {'loc': 'Dubai, UAE', 'cap': 'Burj Khalifa heights. 🇦🇪', 'url': 'https://images.unsplash.com/photo-1512453979798-5ea444f888e3?w=800'},
    ];

    try {
      for (var item in examples) {
        await FirebaseFirestore.instance.collection('posts').add({
          'url': item['url'],
          'caption': item['cap'],
          'location': item['loc'],
          'userName': 'Global Traveler',
          'userId': 'admin_global',
          'type': 'photo',
          'likes': 0,
          'likedBy': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Seeding Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}