import 'package:app_chat/components/chat_bubble.dart';
import 'package:app_chat/components/my_text_field.dart';
import 'package:app_chat/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    // only send message if there is something to send
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserId, _messageController.text);
      // clear the text controller after sending the message
      _messageController.clear();
      _scrollToBottom();
    }
  }

  _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget
              .receivedUserEmail) //Vì đc khai báo ở ngoài lớp state nên phải dùng widget để tham chiếu tới các biến đó
          ),
      body: Column(children: [
        Expanded(
          child: _buildMessageList(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildMessageInput(),
        ),
      ]),
    );
  }

  // build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.receiverUserId,
        _firebaseAuth.currentUser!.uid, // user hiện tại đang đăng nhập
      ),
      builder: (context, snapshot) {
        //snap shot chứa dữ liệu hiện tại của stream
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }
        return ListView(
          key: listKey,
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // align the message to the right if the sender is the current user, otherwise to the left
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            const SizedBox(height: 5),
            ChatBubble(message: data['message']),
          ],
        ),
      ),
    );
  }

  //build message input
  Widget _buildMessageInput() {
    return Row(
      children: [
        // text field
        Expanded(
          child: MyTextField(
            controller: _messageController,
            hintText: 'Enter message',
            obscureText: false,
          ),
        ),
        IconButton(
          onPressed: sendMessage,
          icon: const Icon(
            Icons.arrow_circle_up,
            size: 35,
          ),
        ),
      ],
    );
  }
}
