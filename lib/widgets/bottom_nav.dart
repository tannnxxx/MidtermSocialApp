import 'package:flutter/material.dart';

import '../screens/feed_screen.dart';
import '../screens/create_post_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {

  int currentIndex = 0;

  final screens = const [
    FeedScreen(),
    CreatePostScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: screens[currentIndex],

      bottomNavigationBar: Container(

        margin: const EdgeInsets.all(15),

        decoration: BoxDecoration(

          color: const Color(0xFF111111),

          borderRadius: BorderRadius.circular(30),

          boxShadow: const [
            BoxShadow(
              color: Colors.cyanAccent,
              blurRadius: 15,
              spreadRadius: 1,
            )
          ],
        ),

        child: BottomNavigationBar(

          backgroundColor: Colors.transparent,
          elevation: 0,

          type: BottomNavigationBarType.fixed,

          selectedItemColor: Colors.cyanAccent,
          unselectedItemColor: Colors.grey,

          currentIndex: currentIndex,

          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          items: [

            const BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: "Feed",
            ),

            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withOpacity(0.2),
                ),

                child: const Icon(
                  Icons.add,
                  color: Colors.cyanAccent,
                  size: 28,
                ),
              ),
              label: "Post",
            ),

            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: "Chat",
            ),

            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),

          ],
        ),
      ),
    );
  }
}