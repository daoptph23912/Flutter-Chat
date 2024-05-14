import 'package:flutter/material.dart';

import '../data/data.dart';
import '../model/friend.dart';
import '../model/message.dart';

class ChatScreen extends StatefulWidget {
  final String friendID;
  const ChatScreen({super.key, required this.friendID});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  List<Message> getMessages() {
    return messages
        .where((message) =>
            message.senderId == widget.friendID ||
            message.receiverId == widget.friendID)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final Friend selectedFriend = friendList.firstWhere(
      (friend) => friend.friendID == widget.friendID,
    );

    final List<Message> messagesToShow = getMessages()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(selectedFriend),
            Expanded(child: _buildMessageList(messagesToShow, selectedFriend)),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Friend selectedFriend) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 30, left: 10),
      child: Row(
        children: [

          const SizedBox(width: 20),    IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CircleAvatar(
            backgroundImage: AssetImage(selectedFriend.avatar),
            radius: 20,
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          selectedFriend.isOnline ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedFriend.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                selectedFriend.isOnline ? 'Trực tuyến' : 'Không hoạt động',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
      List<Message> messagesToShow, Friend selectedFriend) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: messagesToShow.length,
      itemBuilder: (context, index) {
        final Message message = messagesToShow[index];
        final bool isMe = message.senderId == widget.friendID;
        return Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe)
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: AssetImage(selectedFriend.avatar),
                  ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF20A090)
                          : const Color(0xFFF2F7FB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.5,
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: isMe
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF000E08),
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                left: isMe ? 0 : (MediaQuery.of(context).size.width * 0.05),
                right: isMe ? (MediaQuery.of(context).size.width * 0.05) : 0,
              ),
              child: Text(
                formatMessageTime(message.timestamp),
                style: const TextStyle(color: Color(0xFF797C7B)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                fillColor: const Color(0xFFEEFAF8),
                filled: true,
                hintText: 'Nhập tin nhắn',
                hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.only(left: 15),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  color: Colors.blue,
                  iconSize: 35,
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {},
          ),
          IconButton(
            icon:
                const ImageIcon(AssetImage('lib/assets/images/iconImage.png')),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final String newMessageContent = _controller.text;
      final Message newMessage = Message(
        id: (messages.length + 1).toString(),
        senderId: "0",
        receiverId: widget.friendID,
        content: newMessageContent,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );
      setState(() {
        messages.add(newMessage);
      });
      _scrollToBottom();
      _controller.clear();
    }
  }

  void _scrollToBottom() {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + keyboardHeight,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
