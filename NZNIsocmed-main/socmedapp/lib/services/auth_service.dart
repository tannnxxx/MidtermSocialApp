import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> register(String email, String password) async {

    try {

      UserCredential result =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;

    } on FirebaseAuthException catch (e) {

      print(e.message);
      return null;
    }
  }

  Future<User?> login(String email, String password) async {

    try {

      UserCredential result =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;

    } on FirebaseAuthException catch (e) {

      print(e.message);
      return null;
    }
  }

  Future logout() async {
    await FirebaseAuth.instance.signOut();
  }
}