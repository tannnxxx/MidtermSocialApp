import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTER
  Future registerUser(String email, String password, String username) async {

    UserCredential user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection("users").doc(user.user!.uid).set({
      "username": username,
      "email": email,
      "uid": user.user!.uid,
    });
  }

  // LOGIN
  Future loginUser(String email, String password) async {

    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // LOGOUT
  Future logoutUser() async {
    await _auth.signOut();
  }
}