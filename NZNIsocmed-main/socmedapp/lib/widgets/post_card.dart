import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/travel_post.dart';
import '../providers/post_provider.dart';

class PostCard extends StatelessWidget {

  final TravelPost post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<PostProvider>(context);

    return Card(

      color: const Color(0xFF111111),

      margin: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 12,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          /// USER HEADER
          ListTile(

            leading: CircleAvatar(
              backgroundImage: NetworkImage(post.profilePic),
            ),

            title: Text(post.username),

            subtitle: Text(post.location),

            trailing: const Icon(Icons.more_vert),
          ),

          /// POST IMAGE
          ClipRRect(

            borderRadius: BorderRadius.circular(10),

            child: Image.network(
              post.mainImage,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          /// ACTION BUTTONS
          Row(

            children: [

              IconButton(

                icon: Icon(
                  post.isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: post.isLiked ? Colors.red : Colors.white,
                ),

                onPressed: () {
                  provider.toggleLike(post);
                },
              ),

              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: () {},
              ),

              IconButton(
                icon: const Icon(Icons.send_outlined),
                onPressed: () {},
              ),
            ],
          ),

          /// LIKES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),

            child: Text(
              "${post.likes} likes",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          /// DESCRIPTION
          Padding(

            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),

            child: RichText(

              text: TextSpan(

                style: const TextStyle(color: Colors.white),

                children: [

                  TextSpan(
                    text: "${post.username} ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextSpan(text: post.description),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}