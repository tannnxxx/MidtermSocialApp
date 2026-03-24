import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file) async {

    final ref = storage.ref().child("posts/${DateTime.now()}");

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }
}