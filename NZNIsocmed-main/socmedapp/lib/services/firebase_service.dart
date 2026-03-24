import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addPost(Map<String, dynamic> data) async {
    await _db.collection("posts").add(data);
  }

  Stream<QuerySnapshot> getPosts() {
    return _db.collection("posts").snapshots();
  }
}