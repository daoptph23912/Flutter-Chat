import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'http://10.2.44.52:8888/api';

  // đăng kí tài khoản
  Future<Map<String, dynamic>> register(
      String fullName, String username, String password) async {
    final String registerUrl = '$baseUrl/auth/register';
    final Map<String, String> data = {
      'FullName': fullName,
      'Username': username,
      'Password': password,
    };

    final http.Response response = await http.post(
      Uri.parse(registerUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  // đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    final String loginUrl = '$baseUrl/auth/login';
    final Map<String, String> data = {
      'Username': username,
      'Password': password,
    };

    final http.Response response = await http.post(
      Uri.parse(loginUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  // cập nhật thông tin người dùng
  Future<Map<String, dynamic>> updateUserInfo(
      String token, String fullName, String avatar) async {
    final String updateUrl = '$baseUrl/user/update';
    final Map<String, String> data = {
      'FullName': fullName,
      'Avatar': avatar,
    };

    final http.Response response = await http.post(
      Uri.parse(updateUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  // lấy thông tin người dùng
  Future<Map<String, dynamic>> getUserInfo(String token) async {
    final String userInfoUrl = '$baseUrl/user/info';

    final http.Response response = await http.get(
      Uri.parse(userInfoUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  // lấy danh sách bạn bè
  Future<Map<String, dynamic>> getListFriends(String token) async {
    final String listFriendsUrl = '$baseUrl/message/list-friend';

    final http.Response response = await http.get(
      Uri.parse(listFriendsUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  // gửi tin nhắn
  Future<Map<String, dynamic>> sendMessage(
      String token, String friendId, String content, String file) async {
    final String sendMessageUrl = '$baseUrl/message/send-message';
    final Map<String, String> data = {
      'FriendID': friendId,
      'Content': content,
      'Files': file,
    };

    final http.Response response = await http.post(
      Uri.parse(sendMessageUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
      body: data,
    );

    return jsonDecode(response.body);
  }

  Future<String> getImage(String imageUrl) async {
      final String getImage = '$baseUrl/images/$imageUrl';
      final response = await http.get(Uri.parse(getImage));
      return response.body;
  }
}
