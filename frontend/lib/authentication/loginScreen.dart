import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/authentication/dangKyScreen.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController _taiKhoanController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();

  bool _isLoading = false;

  final String apiUrl = "https://lms-flutter.onrender.com/auth/login";

  Future<void> dangNhap() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "taiKhoan": _taiKhoanController.text.trim(),
          "matKhau": _matKhauController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"]) {
        final user = data["user"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("userId", user["id"]);
        await prefs.setString("vaiTro", user["vaiTro"]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Chào ${user["hoTen"]} 👋")),
        );

        if (user["vaiTro"] == "admin") {
          Navigator.pushReplacementNamed(context, "/admin");
        } else if (user["vaiTro"] == "hocvien") {
          Navigator.pushReplacementNamed(context, "/hocvien");
        } else {
          Navigator.pushReplacementNamed(context, "/giangvien");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Đăng nhập thất bại")),
        );
      }
    } catch (e) {
      print("Lỗi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi kết nối server")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _taiKhoanController.dispose();
    _matKhauController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _taiKhoanController,
              decoration: const InputDecoration(
                labelText: "Tài khoản",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _matKhauController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : dangNhap,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Đăng nhập"),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Dangkyscreen()),
                );
              },
              child: const Text("Chưa có tài khoản? Đăng ký"),
            ),
          ],
        ),
      ),
    );
  }
}