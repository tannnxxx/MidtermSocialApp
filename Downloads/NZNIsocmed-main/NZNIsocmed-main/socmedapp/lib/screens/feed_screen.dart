import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart'; // Siguraduhing may PostCard ka

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // FUNCTION: LOAD DATA
    // Tinatawag ang Provider para kumuha ng posts mula sa Firebase pagkabukas ng screen.
    Provider.of<PostProvider>(context, listen: false).loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final posts = Provider.of<PostProvider>(context).posts;

    return Scaffold(
      appBar: AppBar(title: const Text("EXPLORE")),
      body: posts.isEmpty
          ? const Center(child: Text("No posts yet. Start sharing!"))
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          // Pinapasa ang data sa PostCard widget
          return PostCard(post: posts[index]);
        },
      ),
    );
  }
}