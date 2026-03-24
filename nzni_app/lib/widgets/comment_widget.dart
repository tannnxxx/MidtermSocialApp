import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {

  final String username;
  final String comment;

  const CommentWidget({
    super.key,
    required this.username,
    required this.comment,
  });

  @override
  Widget build(BuildContext context){

    return ListTile(
      title: Text(username),
      subtitle: Text(comment),
    );
  }
}