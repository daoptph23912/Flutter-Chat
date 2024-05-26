import 'dart:typed_data';
import 'package:chat_app_bkav_/models/message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/friend.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8888/api';

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
      String token, String fullName, String avatarFilePath) async {
    final String updateUrl = '$baseUrl/user/update';

    var request = http.MultipartRequest('POST', Uri.parse(updateUrl))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['FullName'] = fullName
      ..files.add(await http.MultipartFile.fromPath('avatar', avatarFilePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user info');
    }
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
  Future<List<Friend>> getListFriends(String token) async {
    final String listFriendsUrl = '$baseUrl/message/list-friend';

    final http.Response response = await http.get(
      Uri.parse(listFriendsUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      List<Friend> friendList =
          data.map((friendJson) => Friend.fromJson(friendJson)).toList();
      return friendList;
    } else {
      throw Exception('Failed to load friends');
    }
  }

  // gửi tin nhắn
  Future<void> sendMessage(
      String token, String friendID, Message message) async {
    final String sendMessageUrl = '$baseUrl/message/send-message';
    var headers = {
      'Authorization': 'Bearer $token',
    };
    var request = http.MultipartRequest('POST', Uri.parse(sendMessageUrl));
    request.headers.addAll(headers);
    request.fields.addAll({
      'FriendID': friendID,
      'Content': message.content,
    });
    for (var file in message.files) {
      request.files
          .add(await http.MultipartFile.fromPath('files', file.urlFile));
    }

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 1) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

//lấy tin nhắn
  Future<List<Message>> getMessage(String token, String friendID,
      {DateTime? lastTime}) async {
    final String messageUrl = '$baseUrl/message/get-message';
    Uri uri = Uri.parse(messageUrl).replace(queryParameters: {
      'FriendID': friendID,
      if (lastTime != null) 'LastTime': lastTime.toIso8601String(),
    });
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 1 && jsonData.containsKey('data')) {
        final List<dynamic> messageDataList = jsonData['data'];
        return messageDataList
            .map((messageData) => Message.fromJson(messageData))
            .toList();
      } else {
        throw Exception('Không thể lấy tin nhắn: ${jsonData['message']}');
      }
    } else {
      throw Exception('Không thể lấy tin nhắn: ${response.statusCode}');
    }
  }

  //lấy hình ảnh
  Future<Image> loadImage(String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      final String getImageUrl = '$baseUrl/$imageUrl';
      final response = await http.get(Uri.parse(getImageUrl));
      if (response.statusCode == 200) {
        final Uint8List imageBytes = response.bodyBytes;
        return Image.memory(imageBytes);
      }
    }
    return Image.asset('lib/images/iconPerson.png');
  }

  // định dạng thời gian
  String formatMessageTime(DateTime timestamp) {
    final DateFormat formatter = DateFormat('hh:mm a');
    final String formattedTime = formatter.format(timestamp);

    final DateTime now = DateTime.now();
    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

    if (timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day) {
      return formattedTime;
    } else if (timestamp.year == yesterday.year &&
        timestamp.month == yesterday.month &&
        timestamp.day == yesterday.day) {
      return '$formattedTime Hôm qua';
    } else {
      return '${formatter.format(timestamp)} ${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
