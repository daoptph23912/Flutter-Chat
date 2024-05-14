import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_app_bkav_/data/data.dart';
import 'package:chat_app_bkav_/screens/chat_screen.dart';
import '../data/api_service.dart';
import '../data/db_helper.dart';
import '../model/friend.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _imageFile;
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
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBarWidget(
              userName: userName,
              onAvatarSelected: _selectAvatar,
              imageFile: _imageFile,
            ),
            const SizedBox(height: 20),
            SearchBarWidget(
              searchController: _searchController,
              onSearchTextChanged: searchFriends,
              onClearSearch: () {
                _searchController.clear();
                searchFriends('');
              },
            ),
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
            FriendListWidget(
              searchResults: searchResults,
              onFriendTap: (friendID) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      friendID: friendID,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectAvatar() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      DatabaseHelper.instance.saveAvatarPath(userName, _imageFile!.path);
    }
  }

  void searchFriends(String query) {
    searchResults.clear();
    if (query.isEmpty) {
      setState(() {
        searchResults.addAll(friendList);
      });
    } else {
      setState(() {
        searchResults.addAll(friendList.where((friend) =>
            friend.fullName.toLowerCase().contains(query.toLowerCase())));
      });
    }
  }

  Future<void> _getUserInfo() async {
    try {
      Map<String, dynamic> userInfo =
          await ApiService().getUserInfo(widget.token);
      if (userInfo['status'] == 1) {
        setState(() {
          userName = userInfo['data']['Username'];
          fullName = userInfo['data']['FullName'];
          avatar = userInfo['data']['Avatar'];
          print(avatar);
          final a = ApiService().getImage(avatar);
          // Hunter2016@
          print(a);
          _loadAvatar(avatar);
        });
      } else {
        String errorMessage = userInfo['message'];
        // Xử lý thông báo lỗi khi không thể lấy thông tin người dùng
      }
    } catch (error) {
      // Xử lý lỗi khi có lỗi trong quá trình lấy thông tin người dùng
    }
  }

  void _loadAvatar(avatarPath) {
    if (avatarPath.isNotEmpty) {
      setState(() {
        _imageFile = File(avatarPath);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class AppBarWidget extends StatelessWidget {
  final String userName;
  final Function()? onAvatarSelected;
  final File? imageFile;

  const AppBarWidget({
    super.key,
    required this.userName,
    required this.onAvatarSelected,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
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
        IconButton(
          onPressed: onAvatarSelected,
          icon: imageFile != null
              ? CircleAvatar(
                  backgroundImage: FileImage(imageFile!),
                  radius: 20,
                )
              : const Icon(Icons.person),
          iconSize: 42,
        ),
      ],
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchTextChanged;
  final Function() onClearSearch;

  const SearchBarWidget({
    super.key,
    required this.searchController,
    required this.onSearchTextChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      onChanged: onSearchTextChanged,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClearSearch,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class FriendListWidget extends StatelessWidget {
  final List<Friend> searchResults;
  final Function(String) onFriendTap;

  const FriendListWidget({
    super.key,
    required this.searchResults,
    required this.onFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final friend = searchResults[index];
          final isOnline = friend.isOnline;

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(friend.avatar),
              radius: 25,
              child: Stack(
                children: [
                  if (isOnline)
                    Positioned(
                      bottom: 0,
                      right: 5,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                    )
                  else
                    Positioned(
                      bottom: 0,
                      right: 5,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            title: Text(friend.fullName),
            onTap: () => onFriendTap(friend.friendID),
          );
        },
      ),
    );
  }
}
