import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'create_post_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _pages = const [FeedScreen(), CreatePostScreen(), ChatScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onTap: (val) => setState(() => _index = val),
      ),
    );
  }
}