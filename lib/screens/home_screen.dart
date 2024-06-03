import 'package:chat_app_bkav_/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_bkav_/screens/chat_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api_server.dart';
import '../data/data.dart';
import '../models/friend.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Friend> searchResults = [];
  late TextEditingController _searchController;
  String userName = "";
  String fullName = "";
  String avatar = "";
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _getUserInfo();
    searchFriends('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(bottom: 10, right: 10, top: 0, left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBarWidget(context),
            const SizedBox(
              height: 20,
            ),
            _buildSearchBarWidget(),
            const SizedBox(height: 20),
            const Text(
              'Danh sách bạn bè',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            _buildFriendListWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Bkav Chat',
          style: TextStyle(
            color: Color(0xFF1C6DCF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        FutureBuilder<Image>(
          future: ApiService().loadImage('images$avatar'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircleAvatar(
                radius: 20,
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('lib/images/icon-user.png'),
              );
            } else {
              return PopupMenuButton<int>(
                icon: CircleAvatar(
                  backgroundImage: snapshot.data!.image,
                  radius: 20,
                ),
                onSelected: (value) {
                  if (value == 1) {
                    _showChangeNameDialog();
                  } else if (value == 2) {
                    _updateUserInfo();
                  } else if (value == 3) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text(fullName),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text('Change Avatar'),
                  ),
                  const PopupMenuItem(
                    value: 3,
                    child: Text("Log Out"),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchBarWidget() {
    return TextField(
      controller: _searchController,
      onChanged: searchFriends,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _searchController.clear();
            searchFriends('');
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildFriendListWidget() {
    return Expanded(
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final friend = searchResults[index];
          final isOnline = friend.isOnline;

          return FutureBuilder<Image>(
            future: ApiService().loadImage('images${friend.avatar}'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  leading: const CircleAvatar(
                    radius: 25,
                    child: CircularProgressIndicator(),
                  ),
                  title: Text(friend.fullName),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        token: widget.token,
                        friendID: friend.friendID,
                      ),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('lib/images/icon-user.png'),
                    radius: 25,
                  ),
                  title: Text(friend.fullName),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        token: widget.token,
                        friendID: friend.friendID,
                      ),
                    ),
                  ),
                );
              } else {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: snapshot.data!.image,
                    radius: 25,
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
                              color: isOnline ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(friend.fullName),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        token: widget.token,
                        friendID: friend.friendID,
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _showChangeNameDialog() async {
    TextEditingController nameController =
        TextEditingController(text: fullName);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Name'),
          content: TextField(
            controller: nameController,
            onChanged: (value) {
              fullName = value;
            },
            decoration: const InputDecoration(hintText: "Enter new name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                fullName = nameController.text; // cập nhật giá trị fullName
                _updateUserInfo();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _updateUserInfo() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final response = await ApiService()
          .updateUserInfo(widget.token, fullName, pickedFile.path);
      if (response['status'] == 1) {
        _getUserInfo();
        setState(() {});
      } else {
        String errorMessage = response['message'];
        print('-----------Lỗi: $errorMessage');
      }
    }
  }

  Future<void> _getUserInfo() async {
    try {
      Map<String, dynamic> userInfo =
          await ApiService().getUserInfo(widget.token);
      if (userInfo['status'] == 1) {
        setState(() {
          userName = userInfo['data']['Username'] ?? '';
          fullName = userInfo['data']['FullName'] ?? '';
          avatar = userInfo['data']['Avatar'] ?? '';
        });
      } else {
        String errorMessage = userInfo['message'];
        print('Error: $errorMessage');
      }
    } catch (e) {
      print("Lỗi: $e");
    }
  }

  void searchFriends(String query) async {
    searchResults.clear();
    if (query.isEmpty) {
      friendList = await ApiService().getListFriends(widget.token);
      friendList.sort((a, b) =>
          a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
      if (friendList.isNotEmpty) {
        setState(() {
          searchResults.addAll(friendList);
        });
      }
    } else {
      setState(() {
        searchResults.addAll(friendList.where((friend) =>
            friend.fullName.toLowerCase().contains(query.toLowerCase())));
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
