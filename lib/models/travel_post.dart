class TravelPost {

  String id;
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
    this.id = "",
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

  /// Convert to Firestore Map
  Map<String, dynamic> toMap() {

    return {

      "username": username,
      "profilePic": profilePic,
      "location": location,
      "description": description,
      "mainImage": mainImage,
      "videoUrl": videoUrl,
      "likes": likes,
      "comments": comments,

    };
  }

  /// Convert Firestore → TravelPost
  factory TravelPost.fromMap(Map<String, dynamic> map, String id) {

    return TravelPost(

      id: id,

      username: map["username"] ?? "",
      profilePic: map["profilePic"] ?? "",
      location: map["location"] ?? "",
      description: map["description"] ?? "",
      mainImage: map["mainImage"] ?? "",
      videoUrl: map["videoUrl"],

      likes: map["likes"] ?? 0,

      comments: List<String>.from(map["comments"] ?? []),

    );
  }
}