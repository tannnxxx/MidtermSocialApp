import 'dart:io';
import 'package:flutter/material.dart';
import '../models/travel_post.dart';

class PostCard extends StatelessWidget {
  final TravelPost post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5), // Glass effect
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(post.profilePic),
            ),
            title: Text(post.username, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                Text(post.location),
              ],
            ),
          ),

          // Image handling
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
            child: post.mainImage.startsWith("http")
                ? Image.network(post.mainImage, fit: BoxFit.cover, width: double.infinity, height: 250)
                : Image.file(File(post.mainImage), fit: BoxFit.cover, width: double.infinity, height: 250),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.description, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 5),
                    Text("${post.likes} likes"),
                    const SizedBox(width: 20),
                    const Icon(Icons.comment_outlined, color: Colors.blueGrey, size: 20),
                    const SizedBox(width: 5),
                    Text("${post.comments.length} comments"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}