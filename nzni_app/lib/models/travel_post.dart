class TravelPost {

  String username;
  String profilePic;
  String location;
  String description;
  String mainImage;
  String? videoUrl;

  int likes;
  bool isLiked;
  List<String> comments;

  TravelPost({
    required this.username,
    required this.profilePic,
    required this.location,
    required this.description,
    required this.mainImage,
    this.videoUrl,
    this.likes = 0,
    this.isLiked = false,
    List<String>? comments,
  }) : comments = comments ?? [];
}