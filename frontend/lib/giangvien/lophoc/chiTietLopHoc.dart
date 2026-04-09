import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/api.dart';
import 'package:frontend/giangvien/menuUI/giangVienMenuBar.dart';
import 'addBaiHocScreen.dart';
class ChiTietLopHocScreen extends StatefulWidget {
  final int idKhoaHoc;
  const ChiTietLopHocScreen({super.key, required this.idKhoaHoc});

  @override
  State<ChiTietLopHocScreen> createState() => _ChiTietLopHocScreen();
}

class _ChiTietLopHocScreen extends State<ChiTietLopHocScreen> {
  bool isLoading = true;
  Map<String, dynamic>? lopHoc;
  List baiHocs = [];

  final String apiUrl = '${ApiConfig.baseUrl}/giangvien';
  String hoTen = "";
  String vaiTro = "";

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    loadAllData();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hoTen = prefs.getString("hoTen") ?? "";
      vaiTro = prefs.getString("vaiTro") ?? "";
    });
  }

  Future<void> loadAllData() async {
    await Future.wait([loadChiTietLopHoc(), loadBaiHoc()]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadChiTietLopHoc() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");

    final res = await http.get(
      Uri.parse('$apiUrl/lophoc/${widget.idKhoaHoc}'),
      headers: {
        "Content-Type": "application/json",
        "x-user-id": userId.toString(),
      },
    );

    if (res.statusCode == 200) {
      lopHoc = json.decode(res.body)['data'];
    }
  }

  Future<void> loadBaiHoc() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");

    final res = await http.get(
      Uri.parse('$apiUrl/baihoc/${widget.idKhoaHoc}'),
      headers: {
        "Content-Type": "application/json",
        "x-user-id": userId.toString(),
      },
    );

    if (res.statusCode == 200) {
      baiHocs = json.decode(res.body)['data'];
    }
  }

  Future<void> openAddBaiHoc(int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Addbaihocscreen(idKhoaHoc: id),
      ),
    );
    if(result==true){
      loadAllData();
    }
  }

  Icon getIcon(String loai) {
    switch (loai) {
      case 'video':
        return const Icon(Icons.play_circle, color: Colors.blue);
      case 'tailieu':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      default:
        return const Icon(Icons.book);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading ? "Đang tải..." : (lopHoc?['tenKhoaHoc'] ?? "Chi tiết lớp"),
        ),
      ),
      drawer: GiangVienMenuBar(hoTen: hoTen, vaiTro: vaiTro),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lopHoc?['tenKhoaHoc'] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Code: ${lopHoc?['code'] ?? ""}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Danh sách bài học",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: baiHocs.length + 1, 
                    itemBuilder: (context, index) {
                      if (index == baiHocs.length) {
                        return GestureDetector(
                          onTap: () => openAddBaiHoc(widget.idKhoaHoc),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            color: Colors.blue.withOpacity(0.1),
                            child: const ListTile(
                              leading: Icon(Icons.add, color: Colors.blue),
                              title: Text(
                                "Thêm bài học",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      final b = baiHocs[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: getIcon(b['loai'] ?? ''),
                          title: Text(b['tenBaiHoc'] ?? ""),
                          subtitle: Text("Thứ tự: ${b['thuTu'] ?? 0}"),
                          onTap: () {
                            // TODO: chi tiết bài học
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
