import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sfbu_hub/util/graphql_provider.dart';
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
    String email = (await api.LocalStorageApi().getEmail())!;

    chatGroups.add(ChatGroup(
        id: "chat_bot_$email", name: "Personal Assistant", members: []));

    chatGroupUnreadCount["chat_bot_$email"] = 0;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                  contentPadding: const EdgeInsets.all(8.0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatDetailPage(chatGroup: chatGroups[index]),
                      ),
                    ).then((value) => {getChat()});
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
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: isUser ? Colors.green[100] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12.0),
            topRight: const Radius.circular(12.0),
            bottomLeft: !isUser
                ? const Radius.circular(0.0)
                : const Radius.circular(12.0),
            bottomRight: isUser
                ? const Radius.circular(0.0)
                : const Radius.circular(12.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
            const SizedBox(height: 4.0),
            Text(
              text,
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 6.0),
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

  @override
  void initState() {
    super.initState();
    refreshChat();
  }

  @override
  void dispose() {
    api.GraphQlApi().markChatRead(widget.chatGroup.id!);
    super.dispose();
  }

  void refreshChat() async {
    setState(() {
      isLoading = true;
    });
    if (email == "") {
      email = (await api.LocalStorageApi().getEmail())!;
      api.GraphQlApi().markChatRead(widget.chatGroup.id!);
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget createChatPage(List<ChatMessage> chatMessages) {
    return Column(
      children: [
        chatMessages.isEmpty
            ? const Expanded(
                child: Center(child: Text('No messages in this group yet.')))
            : Expanded(
                child: ListView.builder(
                  itemCount: chatMessages.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ChatBubble(
                      text: chatMessages[index].message!,
                      senderName: chatMessages[index].senderName!,
                      isUser: chatMessages[index].senderEmail == email,
                      time: chatMessages[index].createdAt!,
                    );
                  },
                  reverse: true,
                ),
              ),
        const Divider(height: 1.0),
        Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
          child: TextComposer(
            onSubmitted: (String text) async {
              await api.GraphQlApi().sendMessage(
                text,
                widget.chatGroup.id!,
              );
              await api.GraphQlApi().markChatRead(widget.chatGroup.id!);
              refreshChat();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Link link = HttpLink("https://sfbu-hub-2e4eceb65071.herokuapp.com/");
    final webSocketLink =
        WebSocketLink("wss://sfbu-hub-2e4eceb65071.herokuapp.com",
            config: const SocketClientConfig(
              autoReconnect: false,
            ),
            subProtocol: GraphQLProtocol.graphqlTransportWs);
    link = Link.split((request) => request.isSubscription, webSocketLink, link);
    return GraphQLProvider(
      client: ValueNotifier(
        GraphQLClient(
          cache: GraphQLCache(),
          link: link,
        ),
      ),
      child: Subscription(
        options: SubscriptionOptions(
          document: gql('''
              subscription  {
                getChatMessages(course_id: "${widget.chatGroup.id}") {
                  created_at
                  group_id
                  message
                  sender_email
                  sender_name
                }
              }
        '''),
        ),
        builder: (result) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            List<ChatMessage> chatMessages = [];
            // print(result.data!['getChatMessages']);
            for (var message in result.data!['getChatMessages']) {
              chatMessages.add(ChatMessage.fromJson(message));
            }
            chatMessages = chatMessages.reversed.toList();
            api.GraphQlApi().markChatRead(widget.chatGroup.id!);

            return Scaffold(
              appBar: AppBar(
                title: Text(widget.chatGroup.name!,
                    style: const TextStyle(fontSize: 14.0)),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniEndTop,
              floatingActionButton: widget.chatGroup.id!.contains("chat_bot")
                  ? FloatingActionButton(
                      //add hint clear chat
                      onPressed: () {
                        api.GraphQlApi().clearChat(widget.chatGroup.id!);
                      },
                      backgroundColor: Colors.red,
                      tooltip: 'Clear Chat',

                      child: const Icon(Icons.clear),
                    )
                  : null,
              body: createChatPage(chatMessages),
            );
          }
        },
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
