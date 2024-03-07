import 'dart:async';
import 'package:intl/intl.dart';

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
  Map<String, int> chatGroupUnreadCount = {};

  @override
  void initState() {
    getChat();
    super.initState();
  }

  void getChat() async {
    setState(() {
      isLoading = true;
    });

    chatGroups = await api.GraphQlApi().getChatGroups();
    List<ChatRead> chatReads = await api.GraphQlApi().chatReads();
    for (var chatRead in chatReads) {
      chatGroupUnreadCount[chatRead.courseId] = chatRead.count;
    }

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
            splashColor: Colors.green[100],
            trailing: chatGroupUnreadCount[chatGroups[index].id]! > 0
                ? Badge.count(
                    count: chatGroupUnreadCount[chatGroups[index].id]!,
                    backgroundColor: Colors.green[300]!,
                    textStyle: const TextStyle(color: Colors.white),
                  )
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.green[100]!),
            ),
            contentPadding: EdgeInsets.all(8.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatDetailPage(chatGroup: chatGroups[index]),
                ),
              ).then((value) => getChat());
            },
          );
        },
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String senderName;
  final String text;
  final bool isUser;
  final String time;

  const ChatBubble({
    Key? key,
    required this.senderName,
    required this.text,
    required this.isUser,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var parsedDate = DateTime.parse(time).toLocal();
    // var formattedDate = DateFormat.yMMMd().format(parsedDate);
    // format should be 12:00 PM, Jan 1, 2021
    var formattedDate =
        DateFormat.jm().addPattern(' ').add_yMMMMd().format(parsedDate);

    // print(formattedDate);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: isUser ? Colors.green[100] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
            bottomLeft: !isUser ? Radius.circular(0.0) : Radius.circular(12.0),
            bottomRight: isUser ? Radius.circular(0.0) : Radius.circular(12.0),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUser ? Colors.green[900] : Colors.black,
                fontSize: 9.0,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              text,
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 6.0),
            Text(
              formattedDate,
              style: TextStyle(
                color: isUser ? Colors.green[700] : Colors.grey[600],
                fontSize: 12.0,
              ),
            ),
          ],
        ),
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    api.GraphQlApi().markChatRead(widget.chatGroup.id!);
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      refreshChat();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    api.GraphQlApi().markChatRead(widget.chatGroup.id!);
    super.dispose();
  }

  void refreshChat() async {
    // setState(() {
    //   isLoading = true;
    // });
    if (email == "") {
      email = (await api.LocalStorageApi().getEmail())!;
    }
    // print("refreshing chat");
    api.GraphQlApi().markChatRead(widget.chatGroup.id!);
    chatMessages = await api.GraphQlApi().getChatMessages(widget.chatGroup.id!);
    chatMessages = chatMessages.reversed.toList();

    // print(chatMessages);

    // setState(() {
    //   isLoading = false;
    // });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.chatGroup.name!),
        ),
        body: SafeArea(
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      chatMessages.isEmpty
                          ? const Expanded(
                              child: Center(
                                  child:
                                      Text('No messages in this group yet.')))
                          : Expanded(
                              child: ListView.builder(
                                itemCount: chatMessages.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ChatBubble(
                                    text: chatMessages[index].message!,
                                    senderName: chatMessages[index].senderName!,
                                    isUser: chatMessages[index].senderEmail ==
                                        email,
                                    time: chatMessages[index].createdAt!,
                                  );
                                },
                                reverse: true,
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
                            await api.GraphQlApi()
                                .markChatRead(widget.chatGroup.id!);
                            refreshChat();
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ));
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
