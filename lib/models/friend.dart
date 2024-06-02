class Friend {
  final String friendID;
  final String fullName;
  final String username;
  final String avatar;
  final String content;
  final List<dynamic> files;
  final List<dynamic> images;
  final int isSend;
  final bool isOnline;

  Friend({
    required this.friendID,
    required this.fullName,
    required this.username,
    required this.avatar,
    required this.content,
    required this.files,
    required this.images,
    required this.isSend,
    required this.isOnline,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      friendID: json['FriendID'] ?? '',
      fullName: json['FullName'] ?? '',
      username: json['Username'] ?? '',
      avatar: json['Avatar'] ?? '',
      content: json['Content'] ?? '',
      files: json['Files'] ?? [], // Nếu null thì sử dụng danh sách rỗng
      images: json['Images'] ?? [], // Nếu null thì sử dụng danh sách rỗng
      isSend: json['isSend'] ?? 0, // Nếu null thì sử dụng giá trị mặc định là 0
      isOnline: json['isOnline'] ??
          false, // Nếu null thì sử dụng giá trị mặc định là false
    );
  }
}
