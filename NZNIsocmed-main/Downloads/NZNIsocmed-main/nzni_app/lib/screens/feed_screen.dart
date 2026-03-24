import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    return Scaffold(
      backgroundColor: postProvider.isDarkMode ? Colors.black : Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("NZNI EXPLORE", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.blueAccent),
            onPressed: () => postProvider.seedExamplePosts(), // ITO ANG MAGLALAGAY NG 10 SAMPLES
          ),
          IconButton(icon: Icon(postProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode), onPressed: () => postProvider.toggleTheme()),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(hintText: "Search location...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs.where((doc) => doc['location'].toString().toLowerCase().contains(query.toLowerCase())).toList();
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) => PostCard(post: docs[i].data() as Map<String, dynamic>, postId: docs[i].id),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen())),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}