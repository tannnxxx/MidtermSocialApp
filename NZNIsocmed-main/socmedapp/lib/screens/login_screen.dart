import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;

  void login() async {

    if(email.text.isEmpty || password.text.isEmpty){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    final user = await AuthService().login(
      email.text.trim(),
      password.text.trim(),
    );

    setState(() => loading = false);

    if(user != null){

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Wrong email or password"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      body: Center(

        child: Container(
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyanAccent),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              const Text(
                "TRAVEL SOCIAL",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.cyanAccent,
                ),
              ),

              const SizedBox(height:20),

              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
              ),

              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),

              const SizedBox(height:20),

              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: login,
                child: const Text("LOGIN"),
              ),

              TextButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Create Account"),
              )
            ],
          ),
        ),
      ),
    );
  }
}