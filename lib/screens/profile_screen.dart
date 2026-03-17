import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.cyanAccent,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              user?.email ?? "Unknown",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 40),

            ElevatedButton.icon(

              icon: const Icon(Icons.logout),

              label: const Text("Logout"),

              onPressed: () async {

                await AuthService().logout();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                      (route) => false,
                );

              },
            )
          ],
        ),
      ),
    );
  }
}