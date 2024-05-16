import 'package:chat_app_bkav_/data/api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_bkav_/constants/constants.dart';
import 'package:chat_app_bkav_/screens/home_screen.dart';
import 'package:chat_app_bkav_/screens/register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BodyLoginScreen(title: AppConstants.appName),
    );
  }
}

class BodyLoginScreen extends StatefulWidget {
  final String title;

  const BodyLoginScreen({super.key, required this.title});

  @override
  State<BodyLoginScreen> createState() => _BodyLoginScreenState();
}

class _BodyLoginScreenState extends State<BodyLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showErrorMessage = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // tắt bàn phím khi chạm vào màn hình
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          foregroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tài khoản',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Mật khẩu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6783E7),
                ),
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  'Đăng ký',
                  style: TextStyle(color: Color(0xFF047DE7)),
                ),
              ),
              // Hiển thị thông báo lỗi
              if (_showErrorMessage) ...[
                const SizedBox(height: 5),
                Expanded(
                  child: Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty) {
      _showErrorMessageDialog('Tên đăng nhập không được để trống!');
      return;
    } else if (password.isEmpty) {
      _showErrorMessageDialog('Mật khẩu không được để trống!');
      return;
    }

    try {
      List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _showErrorMessageDialog('Không có kết nối mạng!');
        return;
      }
      final Map<String, dynamic> loginResponse =
          await ApiService().login(username, password);

      if (loginResponse['status'] == 1) {
        if (!mounted) return;
        FocusScope.of(context).unfocus();
        String token = loginResponse['data']['token'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(token: token)),
        );
      } else {
        _showErrorMessageDialog(loginResponse['message']);
      }
    } catch (error) {
      _showErrorMessageDialog(
          'Đã xảy ra lỗi khi đăng nhập, vui lòng thử lại sau.');
    }
  }

  void _showErrorMessageDialog(String errorMessage) {
    setState(() {
      _showErrorMessage = true;
      _errorMessage = errorMessage;
    });

    // Tắt thông báo sau 5 giây
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showErrorMessage = false;
        _errorMessage = '';
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }
}