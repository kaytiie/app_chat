import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receivedUserEmail;
  final String receiverUserId;
  const ChatPage(
      {super.key,
      required this.receivedUserEmail,
      required this.receiverUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receivedUserEmail),
      ),
    );
  }
}
