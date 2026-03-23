import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_post.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPost(TravelPost post) async {
    await _firestore.collection("posts").add({
      "username": post.username,
      "profilePic": post.profilePic,
      "location": post.location,
      "description": post.description,
      "mainImage": post.mainImage,
      "likes": post.likes,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Stream<List<TravelPost>> getPosts() {
    return _firestore
        .collection("posts")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return TravelPost(
        username: data["username"] ?? "Anonymous",
        profilePic: data["profilePic"] ?? "",
        location: data["location"] ?? "",
        description: data["description"] ?? "",
        mainImage: data["mainImage"] ?? "",
        likes: data["likes"] ?? 0,
      );
    }).toList());
  }
}