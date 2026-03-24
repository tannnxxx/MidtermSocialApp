import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import '../providers/post_provider.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final String postId;
  const PostCard({super.key, required this.post, required this.postId});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _vController;

  @override
  void initState() {
    super.initState();
    if (widget.post['type'] == 'video') {
      String url = widget.post['url'] ?? "";
      _vController = url.startsWith('http')
          ? VideoPlayerController.network(url)
          : VideoPlayerController.network("data:video/mp4;base64,$url");
      _vController!.initialize().then((_) { if (mounted) setState(() {}); });
    }
  }

  @override
  void dispose() { _vController?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PostProvider>(context, listen: false);
    final currentUid = FirebaseAuth.instance.currentUser?.uid; //dito nag iinteract ang dalawang user
    List likedBy = widget.post['likedBy'] ?? [];
    bool isLiked = likedBy.contains(currentUid);

    return Card(
      margin: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(widget.post['userName'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.post['location'] ?? "Unknown"),
            trailing: widget.post['userId'] == currentUid
                ? IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => p.deletePost(widget.postId)) : null,
          ),
          SizedBox(
            height: 300, width: double.infinity,
            child: widget.post['type'] == 'video'
                ? (_vController != null && _vController!.value.isInitialized ? VideoPlayer(_vController!) : const Center(child: CircularProgressIndicator()))
                : (widget.post['url'].toString().startsWith('http')
                ? Image.network(widget.post['url'], fit: BoxFit.cover)
                : Image.memory(base64Decode(widget.post['url']), fit: BoxFit.cover)),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                IconButton(icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.red), onPressed: () => p.toggleLike(widget.postId, likedBy)),
                Text("${widget.post['likes'] ?? 0}"),
                const SizedBox(width: 15),
                IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () => _showComments(context, p)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15), // FIXED Syntax
            child: Text(widget.post['caption']?.toString() ?? ""), // FIXED Null-safety
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context, PostProvider p) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 15),
          const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 300, child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').orderBy('createdAt', descending: true).snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              return ListView(children: snap.data!.docs.map((d) => ListTile(
                title: Text(d['userName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(d['text']),
              )).toList());
            },
          )),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(children: [
              Expanded(child: TextField(controller: controller, decoration: InputDecoration(hintText: "Add comment...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(30))))),
              IconButton(icon: const Icon(Icons.send), onPressed: () { p.addComment(widget.postId, controller.text); controller.clear(); })
            ]),
          )
        ]),
      ),
    );
  }
}