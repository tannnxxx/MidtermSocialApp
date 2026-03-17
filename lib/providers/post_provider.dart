import 'package:flutter/material.dart';
import '../models/travel_post.dart';

class PostProvider extends ChangeNotifier {

  final List<TravelPost> _posts = [

    TravelPost(
      username: "Wanderlust_Diaries",
      profilePic: "https://i.pravatar.cc/150?img=10",
      location: "Santorini, Greece",
      description: "Sunsets in Oia are magical 🌅",
      mainImage:
      "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
      likes: 120,
    ),

    TravelPost(
      username: "ZenTraveler",
      profilePic: "https://i.pravatar.cc/150?img=44",
      location: "Kyoto, Japan",
      description: "Peaceful bamboo forest 🌿",
      mainImage:
      "https://images.unsplash.com/photo-1501785888041-af3ef285b470",
      likes: 230,
    ),

    TravelPost(
      username: "IslandHopper",
      profilePic: "https://i.pravatar.cc/150?img=5",
      location: "Maldives",
      description: "Walking on sunshine ☀️",
      mainImage:
      "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
      likes: 540,
    ),

  ];

  List<TravelPost> get posts => _posts;

  void toggleLike(TravelPost post) {

    post.isLiked = !post.isLiked;

    if (post.isLiked) {
      post.likes++;
    } else {
      post.likes--;
    }

    notifyListeners();
  }

  void addComment(TravelPost post, String comment) {

    post.comments.add(comment);
    notifyListeners();
  }
}