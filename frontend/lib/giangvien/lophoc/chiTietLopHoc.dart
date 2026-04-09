import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/api.dart';
import 'package:frontend/giangvien/menuUI/giangVienMenuBar.dart';

class ChiTietLopHocScreen extends StatefulWidget {
  final int idKhoaHoc;
  const ChiTietLopHocScreen({super.key, required this.idKhoaHoc});

  @override
  State<ChiTietLopHocScreen> createState() => _ChiTietLopHocScreen();
}

class _ChiTietLopHocScreen extends State<ChiTietLopHocScreen> {
  bool isLoading = true;
  Map<String, dynamic>? lopHoc;

  final String apiUrl = '${ApiConfig.baseUrl}/giangvien/lophoc';
  String hoTen = "";
  String vaiTro = "";
  @override
  void initState() {
    super.initState();
    loadUserInfo();
    loadChiTietLopHoc();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hoTen = prefs.getString("hoTen") ?? "";
      vaiTro = prefs.getString("vaiTro") ?? "";
    });
  }

  Future<void> loadChiTietLopHoc() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");
      final response = await http.get(
        Uri.parse('$apiUrl/${widget.idKhoaHoc}'),
        headers: {
          "Content-Type": "application/json",
          "x-user-id": userId != null ? userId.toString() : "",
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          lopHoc = json.decode(response.body)['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Lỗi load data');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading ? "Đang tải..." : (lopHoc?['tenKhoaHoc'] ?? "Quản lý lớp"),
        ),
      ),
      drawer: GiangVienMenuBar(hoTen: hoTen, vaiTro: vaiTro),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : lopHoc == null
          ? const Center(child: Text("Không tìm thấy dữ liệu lớp học"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tên lớp: ${lopHoc!['tenKhoaHoc']}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Mô tả: ${lopHoc!['moTa'] ?? 'Không có mô tả'}"),
                  // Thêm các thông tin khác tùy ý...
                ],
              ),
            ),
    );
  }
}
