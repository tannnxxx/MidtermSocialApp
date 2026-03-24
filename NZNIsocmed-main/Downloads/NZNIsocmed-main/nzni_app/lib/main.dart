import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/post_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Siguraduhing maayos ang Firebase bago i-run ang app
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Init Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Dito natin sinisimulan ang PostProvider at tinatawag ang loadPosts
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: Consumer<PostProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false, // Tinanggal ang Debug Banner
            title: 'NZNI Social',

            // --- DYNAMIC THEMING ---
            // Dito magbabago ang kulay ng buong app depende sa switch sa Profile
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xFFF0F7FF),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF1A237E),
                elevation: 0,
              ),
              useMaterial3: true,
            ),

            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              useMaterial3: true,
            ),

            // --- AUTH NAVIGATION ---
            // Nakikinig sa authStateChanges: Kapag naka-login, diretso sa Home.
            // Kapag nag-logout, babalik sa Login.
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                // Habang chine-check ang login status
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator(color: Colors.blue)),
                  );
                }

                // Kung may user na naka-login
                if (snapshot.hasData) {
                  return const HomeScreen();
                }

                // Kung walang naka-login o nag-logout
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}