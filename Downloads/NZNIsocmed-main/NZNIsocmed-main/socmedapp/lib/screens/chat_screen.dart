import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final user = FirebaseAuth.instance.currentUser;
  bool isAiTyping = false;

  // --- AI KNOWLEDGE (SUGGESTED COUNTRIES - NANATILI) ---
  final Map<String, String> _aiKnowledge = {
    "japan": "Japan is famous for Sakura and Sushi! 🌸",
    "korea": "Annyeong! Try the street food in Myeongdong. 🇰🇷",
    "philippines": "Mabuhay! Palawan is the most beautiful island. 🇵🇭",
    "france": "Bonjour! Don't miss the Eiffel Tower. 🗼",
    "thailand": "Sawatdee! Enjoy the beaches and street food in Bangkok. 🇹🇭🏝️",
  };

  void sendMessage() async {
    String text = controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();

    // Gamitin ang iyong actual profile URL mula sa Firebase Auth
    // Maglalagay tayo ng fallback image kung sakaling null ang photoURL
    String myPic = user?.photoURL ?? "https://cdn-icons-png.flaticon.com/512/149/149071.png";

    try {
      await FirebaseFirestore.instance.collection("messages").add({
        "text": text,
        "sender": "Me",
        "profilePic": myPic,
        "time": DateTime.now(),
      });

      setState(() => isAiTyping = true);
      _aiResponse(text);
      _scrollToBottom();
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  void _aiResponse(String msg) {
    String response = "That's a great choice! Where would you like to go next?";
    String lowerMsg = msg.toLowerCase();

    _aiKnowledge.forEach((key, value) {
      if (lowerMsg.contains(key)) response = value;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        FirebaseFirestore.instance.collection("messages").add({
          "text": response,
          "sender": "AI",
          "profilePic": "https://cdn-icons-png.flaticon.com/512/4712/4712035.png",
          "time": DateTime.now(),
        });
        setState(() => isAiTyping = false);
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Text("TRAVEL AI", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background UI Decorations
          Positioned(top: -50, right: -50, child: _buildBlurBlob(Colors.blue.withOpacity(0.2), 250)),
          Positioned(bottom: 100, left: -50, child: _buildBlurBlob(Colors.purple.withOpacity(0.1), 200)),

          Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("messages").orderBy("time", descending: true).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) return const Center(child: Text("May problema sa koneksyon."));
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Simulan ang iyong travel journey!"));

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.only(top: 120, bottom: 20, left: 15, right: 15),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        bool isMe = data['sender'] == "Me";
                        return _buildChatBubble(
                          message: data['text'] ?? "",
                          profilePic: data['profilePic'] ?? "",
                          time: (data['time'] as Timestamp).toDate(),
                          isMe: isMe,
                          isDark: isDark,
                        );
                      },
                    );
                  },
                ),
              ),
              if (isAiTyping)
                const Padding(
                  padding: EdgeInsets.only(left: 65, bottom: 10),
                  child: Row(children: [Text("AI is thinking...", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey))]),
                ),
              _buildMessageInput(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble({required String message, required String profilePic, required DateTime time, required bool isMe, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) CircleAvatar(radius: 18, backgroundImage: NetworkImage(profilePic)),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF1E88E5) : (isDark ? Colors.white10 : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 5),
                  bottomRight: Radius.circular(isMe ? 5 : 20),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(message, style: TextStyle(color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87), fontSize: 15)),
                  const SizedBox(height: 5),
                  Text(DateFormat('hh:mm a').format(time), style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (isMe) CircleAvatar(radius: 18, backgroundImage: NetworkImage(profilePic)),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: "Ask about a country...", border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 20)),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send_rounded, color: Color(0xFF1E88E5)), onPressed: sendMessage),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlurBlob(Color color, double size) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}