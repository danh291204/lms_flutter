import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'addUserScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/admin/menuUI/adminMenuBar.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List users = [];
  bool isLoading = true;

  final String apiUrl = 'https://lms-flutter.onrender.com/admin/nguoidung';
  String hoTen = "";
  String vaiTro = "";

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    fetchUsers();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hoTen = prefs.getString("hoTen") ?? "";
      vaiTro = prefs.getString("vaiTro") ?? "";
    });
  }

  Future<void> fetchUsers() async {
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
          users = data;
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

  Future<void> timKiemUsers(String keyword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");
      final response = await http.get(
        Uri.parse('$apiUrl/search?taiKhoan=$keyword'),
        headers: {
          "Content-Type": "application/json",
          "x-user-id": userId != null ? userId.toString() : "",
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> openAddUserScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddUserScreen()),
    );
    if (result == true) {
      fetchUsers();
    }
  }

  Future<void> xoaUser(int id) async {
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
        fetchUsers();
      } else {
        throw Exception("Xóa thất bại");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> openUpdateUser(Map<String, dynamic> user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddUserScreen(user: user)),
    );
    if (result == true) {
      fetchUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách User')),
      drawer: AdminMenuBar(hoTen: hoTen, vaiTro: vaiTro),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tài khoản...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                fetchUsers();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        fetchUsers();
                      } else {
                        timKiemUsers(value);
                      }
                    },
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
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
                                backgroundColor: Colors.blue,
                                child: Text(
                                  user['hoTen'] != null &&
                                          user['hoTen'].isNotEmpty
                                      ? user['hoTen'][0].toUpperCase()
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          user['hoTen'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: user['trangThai'] == true
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            user['trangThai'] == true
                                                ? 'Hoạt động'
                                                : 'Khóa',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),
                                    Text('${user['taiKhoan'] ?? ''}'),
                                    Text('${user['email'] ?? ''}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${user['vaiTro'] ?? 'hocvien'}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      openUpdateUser(user);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      xoaUser(user['idNguoiDung']);
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
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddUserScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
