import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/admin/menuUI/adminMenuBar.dart';
import 'addClassScreen.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  List classes = [];
  bool isLoading = true;

  final String apiUrl = 'https://lms-flutter.onrender.com/admin/lophoc';

  String hoTen = "";
  String vaiTro = "";

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    fetchClasses();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hoTen = prefs.getString("hoTen") ?? "";
      vaiTro = prefs.getString("vaiTro") ?? "";
    });
  }

  Future<void> fetchClasses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "x-user-id": userId != null ? userId.toString() : "",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          classes = data;
          isLoading = false;
        });
      } else {
        throw Exception("Lỗi load lớp học");
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> xoaClass(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");

      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {
          "Content-Type": "application/json",
          "x-user-id": userId != null ? userId.toString() : "",
        },
      );

      if (response.statusCode == 200) {
        fetchClasses();
      } else {
        throw Exception("Xóa thất bại");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> openAddClassScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddClassScreen()),
    );
    if (result == true) {
      fetchClasses();
    }
  }

  Future<void> openUpdateClass(Map<String, dynamic> lop) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddClassScreen(khoahoc: lop)),
    );
    if (result == true) {
      fetchClasses();
    }
  }

  Future<void> confirmDelete(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Xóa lớp học này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      xoaClass(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách lớp học')),

      drawer: AdminMenuBar(hoTen: hoTen, vaiTro: vaiTro),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final lop = classes[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.orange,
                          child: Text(
                            lop['tenKhoaHoc'] != null &&
                                    lop['tenKhoaHoc'].isNotEmpty
                                ? lop['tenKhoaHoc'][0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lop['tenKhoaHoc'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(lop['moTa'] ?? ''),
                              Text("Danh mục: ${lop['danhMuc'] ?? ''}"),

                              const SizedBox(height: 4),

                              Text(
                                "Code: ${lop['code'] ?? ''}",
                                style: const TextStyle(color: Colors.blue),
                              ),

                              const SizedBox(height: 4),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: lop['trangThai'] == true
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  lop['trangThai'] == true ? 'Đang mở' : 'Đóng',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                openUpdateClass(lop);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                confirmDelete(lop['idKhoaHoc']);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          openAddClassScreen();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
