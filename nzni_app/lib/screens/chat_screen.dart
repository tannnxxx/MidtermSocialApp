import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/post_provider.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool isAiTyping = false;

  final Map<String, String> _aiKnowledge = {
    "japan": "Japan is famous for Sakura 🌸 and Sushi! Visit Tokyo.",
    "korea": "Annyeong! Try the street food in Myeongdong. 🇰🇷",
    "philippines": "Mabuhay! Palawan has the best beaches. 🇵🇭",
    "france": "Bonjour! Don't miss the Eiffel Tower. 🗼",
    "thailand": "Sawatdee! Enjoy the street food in Bangkok. 🇹🇭",
    "usa": "NYC and Grand Canyon are top picks! 🇺🇸",
    "italy": "Pizza in Naples is a must-try! 🇮🇹🍕",
  };

  void sendMessage() async {
    String text = controller.text.trim();
    if (text.isEmpty) return;
    controller.clear();

    await FirebaseFirestore.instance.collection("messages").add({
      "text": text, "sender": "Me", "profilePic": user?.photoURL ?? "", "time": DateTime.now(),
    });

    setState(() => isAiTyping = true);
    Future.delayed(const Duration(seconds: 1), () {
      String response = "Great choice! Tell me more.";
      _aiKnowledge.forEach((k, v) { if (text.toLowerCase().contains(k)) response = v; });

      FirebaseFirestore.instance.collection("messages").add({
        "text": response, "sender": "AI", "profilePic": "https://cdn-icons-png.flaticon.com/512/4712/4712035.png", "time": DateTime.now(),
      });
      setState(() => isAiTyping = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<PostProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0F7FF),
      appBar: AppBar(title: const Text("TRAVEL AI"), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("messages").orderBy("time", descending: true).snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                return ListView.builder(reverse: true, itemCount: docs.length, itemBuilder: (ctx, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  bool isMe = d['sender'] == "Me";
                  return ListTile(
                    title: Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isMe ? Colors.blue : (isDark ? Colors.white10 : Colors.white), borderRadius: BorderRadius.circular(10)),
                            child: Text(d['text'] ?? "", style: TextStyle(color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black))))),
                  );
                });
              },
            ),
          ),
          if (isAiTyping) const Text("AI is thinking...", style: TextStyle(fontSize: 10)),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(controller: controller, decoration: InputDecoration(hintText: "Ask AI...", suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: sendMessage), filled: true, fillColor: isDark ? Colors.white10 : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none))),
          ),
        ],
      ),
    );
  }
}