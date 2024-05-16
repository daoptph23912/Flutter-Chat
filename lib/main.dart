import 'package:flutter/material.dart';
import 'package:chat_app_bkav_/screens/login_screen.dart';
import 'package:chat_app_bkav_/theme/theme.dart';
// import 'package:chat_app_bkav_/screens/home_screen.dart';
// import 'package:chat_app_bkav_/screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'welcome',
      theme: lightMode,
      home: const LoginScreen(
          // token: 'asasasa',
          ),
    );
  }
}
