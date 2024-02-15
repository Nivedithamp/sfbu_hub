import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sfbu_hub/models/models.dart';
import 'package:sfbu_hub/api_layer/api.dart' as api;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  bool isLoading = false;
  List<ChatGroup> chatGroups = [];

  void initState() {
    getChat();
    super.initState();
  }

  void getChat() async {
    setState(() {
      isLoading = true;
    });

    chatGroups = await api.GraphQlApi().getChatGroups();
    print(chatGroups);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        itemCount: chatGroups.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(chatGroups[index].name!),
            subtitle: Text(chatGroups[index].name!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatDetailPage(chatGroup: chatGroups[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final String senderName; // New parameter for sender's name
  final bool isUser;

  ChatBubble(this.text, this.senderName, this.isUser);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.topRight : Alignment.topLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isUser ? "You" : senderName, // Display sender's name
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue : Colors.green,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final ChatGroup chatGroup;

  const ChatDetailPage({required this.chatGroup, super.key});

  @override
  State<ChatDetailPage> createState() => ChatDetailPageState();
}

class ChatDetailPageState extends State<ChatDetailPage> {
  bool isLoading = false;
  List<ChatMessage> chatMessages = [];
  String email = "";

  @override
  void initState() {
    super.initState();
    refreshChat();
  }

  void refreshChat() async {
    setState(() {
      isLoading = true;
    });
    if (email == "") {
      email = (await api.LocalStorageApi().getEmail())!;
    }

    chatMessages = await api.GraphQlApi().getChatMessages(widget.chatGroup.id!);
    print(chatMessages);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatGroup.name!),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: chatMessages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ChatBubble(
                          chatMessages[index].message!,
                          chatMessages[index].senderName!,
                          chatMessages[index].senderEmail == email,
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1.0),
                  Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).cardColor),
                    child: TextComposer(
                      onSubmitted: (String text) async {
                        await api.GraphQlApi().sendMessage(
                          text,
                          widget.chatGroup.id!,
                        );
                        refreshChat();
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class TextComposer extends StatefulWidget {
  final Function(String) onSubmitted;

  const TextComposer({required this.onSubmitted, super.key});

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: (String text) {
                widget.onSubmitted(text);
                _textController.clear();
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              widget.onSubmitted(_textController.text);
              _textController.clear();
            },
          ),
        ],
      ),
    );
  }
}
