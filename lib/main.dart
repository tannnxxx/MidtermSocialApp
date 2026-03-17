import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'providers/post_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light, // Switched to light for a fresh travel feel
          scaffoldBackgroundColor: Colors.white,

          // Changing Orbitron (Sci-Fi) to a cleaner Travel font like Montserrat or Poppins
          textTheme: GoogleFonts.montserratTextTheme(
            ThemeData.light().textTheme,
          ),

          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1E88E5), // Ocean Blue
            secondary: Color(0xFFFFAB40), // Sunset Orange
            surface: Colors.white,
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}