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
        // token:
        //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1dWlkIjoiNjYxNjUwMDYxMjQzYmNkZjE1MDQzNGUxIiwiRnVsbE5hbWUiOiJIaeG6v3UgUEMiLCJpYXQiOjE3MTI3MzgzMTAsImV4cCI6MzMyNDg3MzgzMTB9.qZOaD4MDvaFRoKybdrhQJTXx-L0hVGRw2PrfTqR0by4',
      ),
    );
  }
}
