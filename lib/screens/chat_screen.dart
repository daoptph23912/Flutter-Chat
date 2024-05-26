import 'dart:io';
import 'package:chat_app_bkav_/api/api_server.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import '../data/data.dart';
import '../models/friend.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String friendID;
  final String token;

  const ChatScreen({super.key, required this.token, required this.friendID});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _emojiOpen = false;
  bool _imagePickerOpen = false;
  List<AssetEntity> _images = [];
  @override
  void initState() {
    super.initState();
    _getMessages();
    _requestPermissionAndLoadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : messageList.isEmpty
                      ? const Center(child: Text('Chưa có cuộc trò chuyện'))
                      : _buildMessageList(),
            ),
            _buildSendMessage(),
            if (_emojiOpen) _buildEmojiPicker(),
            if (_imagePickerOpen) _buildImagePicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final Friend selectedFriend = friendList.firstWhere(
      (friend) => friend.friendID == widget.friendID,
    );

    return FutureBuilder<Image>(
      future: ApiService().loadImage('images${selectedFriend.avatar}'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return _buildHeaderContent(
            selectedFriend,
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('lib/images/iconPerson.png'),
            ),
          );
        } else {
          return _buildHeaderContent(
            selectedFriend,
            CircleAvatar(
              backgroundImage: snapshot.data?.image,
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
          );
        }
      },
    );
  }

  Widget _buildHeaderContent(Friend selectedFriend, CircleAvatar avatar) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 30, left: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          avatar,
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

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: messageList.length,
      itemBuilder: (context, index) {
        final message = messageList[index];
        final bool isMe = message.messageType == 1;
        return Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe)
                  // Hiển thị avatar bạn bè
                  FutureBuilder<Image>(
                    future: ApiService().loadImage(
                        'images${friendList.firstWhere((friend) => message.messageType == 0).avatar}'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey,
                        );
                      } else if (snapshot.hasError) {
                        return const CircleAvatar(
                          radius: 15,
                          backgroundImage:
                              AssetImage('lib/images/iconPerson.png'),
                        );
                      } else {
                        return CircleAvatar(
                          radius: 15,
                          backgroundImage: snapshot.data?.image,
                        );
                      }
                    },
                  ),
                // Hiển thị tin nhắn
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
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.5,
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.content,
                            style: TextStyle(
                              color: isMe
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF000E08),
                            ),
                            softWrap: true,
                          ),
                          if (message.files.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: message.files.map((fileData) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisAlignment: isMe
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.insert_drive_file,
                                          color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fileData.fileName,
                                              style: TextStyle(
                                                color: isMe
                                                    ? const Color(0xFFFFFFFF)
                                                    : const Color(0xFF000E08),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${(20000 / 1024).toStringAsFixed(2)} KB',
                                              style: TextStyle(
                                                color: isMe
                                                    ? const Color(0xFFFFFFFF)
                                                    : const Color(0xFF000E08),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Hiển thị hình ảnh nếu có
            if (message.images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: message.images.map((imageData) {
                    return FutureBuilder<Image>(
                      future: ApiService().loadImage(imageData.urlImage),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            width: 256,
                            height: 256,
                            color: Colors.grey,
                          );
                        } else if (snapshot.hasError) {
                          return Container(
                            width: 256,
                            height: 256,
                            color: Colors.red,
                            child: const Icon(Icons.error, size: 50),
                          );
                        } else {
                          return Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 256,
                            height: 256,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: snapshot.data,
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            // Hiển thị thời gian
            Padding(
              padding: EdgeInsets.only(
                left: isMe ? 0 : (MediaQuery.of(context).size.width * 0.05),
                right: isMe ? (MediaQuery.of(context).size.width * 0.05) : 0,
              ),
              child: Text(
                ApiService().formatMessageTime(message.createdAt),
                style: const TextStyle(color: Color(0xFF797C7B)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSendMessage() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            onPressed: () {
              setState(() {
                _emojiOpen = !_emojiOpen;
                _imagePickerOpen = false;
              });
            },
          ),
          Expanded(
            child: TextField(
              controller: _textEditController,
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
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {},
          ),
          IconButton(
            icon: const ImageIcon(AssetImage('lib/images/iconImage.png')),
            onPressed: () {
              setState(() {
                _imagePickerOpen = !_imagePickerOpen;
                _emojiOpen = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        _textEditController.text += emoji.emoji;
      },
      config: Config(
        height: 256,
        checkPlatformCompatibility: true,
        emojiViewConfig: EmojiViewConfig(
          emojiSizeMax: 28 *
              (foundation.defaultTargetPlatform == TargetPlatform.android
                  ? 1.20
                  : 1.0),
        ),
        swapCategoryAndBottomBar: false,
        skinToneConfig: const SkinToneConfig(),
        categoryViewConfig: const CategoryViewConfig(),
        bottomActionBarConfig: const BottomActionBarConfig(),
        searchViewConfig: const SearchViewConfig(),
      ),
    );
  }

  Widget _buildImagePicker() {
    return SizedBox(
      height: 216,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final image = _images[index];
          return FutureBuilder<File?>(
            future: image.file,
            builder: (context, snapshot) {
              final file = snapshot.data;
              if (file == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return GestureDetector(
                onTap: () {
                  // Handle image selection
                  _selectImage(image);
                },
                child: Image.file(file, fit: BoxFit.cover),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _getMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messages =
          await ApiService().getMessage(widget.token, widget.friendID);
      setState(() {
        messageList = messages;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error when fetching messages
      print('Error fetching messages: $e');
    }
  }

  void _sendMessage() async {
    if (_textEditController.text.isNotEmpty) {
      final String newMessageContent = _textEditController.text;
      final Message newMessage = Message(
        id: '',
        content: newMessageContent,
        createdAt: DateTime.now(),
        messageType: 1,
        isSend: 0,
        files: [],
        images: [],
      );

      // Gửi tin nhắn lên server
      await ApiService().sendMessage(widget.token, widget.friendID, newMessage);

      // Cập nhật UI
      setState(() {
        messageList.add(newMessage);
      });
      _textEditController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _selectImage(AssetEntity image) {
    image.file.then((File? file) {
      if (file != null) {
        Message newMessage = Message(
          id: '',
          content: '',
          createdAt: DateTime.now(),
          messageType: 1,
          isSend: 0,
          files: [],
          images: [
            ImageData(
                urlImage: file.path,
                fileName: file.path.split('/').last,
                id: '')
          ],
        );
        ApiService().sendMessage(widget.token, widget.friendID, newMessage);
        setState(() {
          messageList.add(newMessage);
          _imagePickerOpen = false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _requestPermissionAndLoadImages() async {
    PermissionStatus status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      openAppSettings();
    } else if (status.isGranted) {
      final albums =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      if (albums.isNotEmpty) {
        final recentAlbum = albums.first;
        final recentImages =
            await recentAlbum.getAssetListPaged(page: 0, size: 100);
        setState(() {
          _images = recentImages;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _textEditController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
