import 'package:flutter/material.dart';
import '../models/travel_post.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();
  List<TravelPost> _posts = [];

  List<TravelPost> get posts => _posts;

  void loadPosts() {
    // 1. Makinig sa real-time updates mula sa Firebase
    _postService.getPosts().listen((data) {
      if (data.isEmpty) {
        // 2. Kung walang laman ang Firebase, ipakita ang Sample Posts
        _posts = _getSamplePosts();
      } else {
        _posts = data;
      }
      notifyListeners();
    });
  }

  // SAMPLE DATA PARA SA FEED
  List<TravelPost> _getSamplePosts() {
    return [
      TravelPost(
        username: "Juan Dela Cruz",
        profilePic: "https://i.pravatar.cc/150?img=11",
        location: "El Nido, Palawan",
        description: "Waking up to this paradise! 🌊 #TravelPH",
        mainImage: "https://images.unsplash.com/photo-1518509562904-e7ef99cdcc86",
        likes: 124,
        comments: ["Ganda!", "Sana all!"],
      ),
      TravelPost(
        username: "Maria Clara",
        profilePic: "https://i.pravatar.cc/150?img=5",
        location: "Batanes, Philippines",
        description: "The hills are alive! Such a peaceful place. ⛰️",
        mainImage: "https://images.unsplash.com/photo-1505033575518-a36ea2ef75ae",
        likes: 89,
        comments: ["My dream destination!"],
      ),
    ];
  }

  void addComment(TravelPost post, String comment) {
    post.comments.add(comment);
    notifyListeners();
  }
}