import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/post_provider.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatelessWidget {

  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<PostProvider>(context);

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "TravelGram",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),

      body: ListView.builder(

        itemCount: provider.posts.length,

        itemBuilder: (context, index) {

          final post = provider.posts[index];

          return PostCard(post: post);
        },
      ),
    );
  }
}