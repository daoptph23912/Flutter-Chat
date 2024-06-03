import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_bkav_/api/api_server.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(text: "123");
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController(text: "123");
  bool _showErrorMessage = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Tạo tài khoản',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'Tên hiển thị',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextField(
              controller: _fullnameController,
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tài khoản',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 10),
            const Text(
              'Mật khẩu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 10),
            const Text(
              'Nhập lại mật khẩu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 110),
            ElevatedButton(
              onPressed: () {
                _registerUser();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFF6783E7),
              ),
              child: const Text(
                'Tạo tài khoản',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (_showErrorMessage) ...[
              const SizedBox(height: 5),
              Expanded(
                child: Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _registerUser() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String fullName = _fullnameController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        fullName.isEmpty) {
      _showErrorMessageDialog('Vui lòng điền đầy đủ thông tin!');
      return;
    }

    if (password != confirmPassword) {
      _showErrorMessageDialog('Mật khẩu nhập lại không khớp!');
      return;
    }
    // Kiểm tra xem có kết nối mạng không
    try {
      List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _showErrorMessageDialog('Không có kết nối mạng!');
        return;
      }

      // Gửi yêu cầu đăng ký tài khoản
      Map<String, dynamic> registerResponse =
          await ApiService().register(fullName, username, password);

      if (registerResponse['status'] == 1) {
        String token = registerResponse['data']['token'];
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(token: token)),
        );
      } else {
        String errorMessage = registerResponse['message'];
        _showErrorMessageDialog(errorMessage);
      }
    } catch (error) {
      _showErrorMessageDialog(
          'Đã xảy ra lỗi khi đăng ký, vui lòng thử lại sau!');
    }
  }

  void _showErrorMessageDialog(String errorMessage) {
    if (!mounted) return;
    setState(() {
      _showErrorMessage = true;
      _errorMessage = errorMessage;
    });

    // Tắt thông báo sau 5 giây
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _showErrorMessage = false;
        _errorMessage = '';
      });
    });
  }

  @override
  void dispose() {
    // Loại bỏ thông báo lỗi trước khi dispose widget
    if (_showErrorMessage) {
      setState(() {
        _showErrorMessage = false;
        _errorMessage = '';
      });
    }
    super.dispose();
  }
}
