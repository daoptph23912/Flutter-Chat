import 'package:intl/intl.dart';

import '../model/friend.dart';
import '../model/message.dart';

// Danh sách bạn bè
final List<Friend> friendList = [
  Friend(
    friendID: "1",
    fullName: "Bạn A",
    avatar: "lib/assets/images/iconPerson.png",
    isOnline: true,
    username: "a",
  ),
  Friend(
    friendID: "2",
    fullName: "Bạn B",
    avatar: "lib/assets/images/iconPerson.png",
    isOnline: true,
    username: "b",
  ),
  Friend(
    friendID: "3",
    fullName: "Bạn C",
    avatar: "lib/assets/images/iconPerson.png",
    isOnline: false,
    username: "c",
  ),
];
// Danh sách tin nhắn
List<Message> messages = [
  Message(
    id: "1",
    senderId: "0",
    receiverId: "1",
    content: "Xin chào!",
    timestamp: DateTime.now().subtract(const Duration(hours: 70)),
    type: MessageType.text,
  ),
  Message(
    id: "2",
    senderId: "1",
    receiverId: "0",
    content: "Chào bạn!",
    timestamp: DateTime.now().subtract(const Duration(hours: 20)),
    type: MessageType.text,
  ),
  Message(
    id: "3",
    senderId: "0",
    receiverId: "1",
    content: "Có gì mới?",
    timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    type: MessageType.text,
  ),
  Message(
    id: "4",
    senderId: "1",
    receiverId: "0",
    content: "Không có gì đặc biệt!",
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    type: MessageType.text,
  ),
];

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
