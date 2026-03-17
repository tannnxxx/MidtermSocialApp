import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {

  File? image;

  final caption = TextEditingController();
  final location = TextEditingController();

  Future pickImage() async {

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if(picked != null){

      setState(() {
        image = File(picked.path);
      });

    }
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(title: const Text("Create Post")),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            image != null
                ? Image.file(image!, height:200)
                : const Text("No image selected"),

            const SizedBox(height:20),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),

            TextField(
              controller: caption,
              decoration: const InputDecoration(
                labelText: "Caption",
              ),
            ),

            TextField(
              controller: location,
              decoration: const InputDecoration(
                labelText: "Location",
              ),
            ),
          ],
        ),
      ),
    );
  }
}