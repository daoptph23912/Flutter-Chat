class User {
  final String userName;
  final String fullName;
  final String avatar;

  User({
    required this.userName,
    required this.fullName,
    required this.avatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'fullName': fullName,
      'avatar': avatar,
    };
  }

  @override
  String toString() {
    return 'User{ userName: $userName, fullName: $fullName, avatar: $avatar }';
  }
}
