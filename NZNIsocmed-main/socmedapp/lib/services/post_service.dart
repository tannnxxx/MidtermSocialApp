import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_post.dart';

class PostService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future addPost(TravelPost post) async {

    await _db.collection("posts").add(post.toMap());
  }

  Stream<List<TravelPost>> getPosts(){

    return _db.collection("posts")
        .orderBy("likes", descending: true)
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc){

        return TravelPost.fromMap(doc.data(), doc.id);

      }).toList();

    });
  }
}