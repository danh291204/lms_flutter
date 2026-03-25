import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key, this.user});
  final Map<String, dynamic>? user;

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController hoTenController = TextEditingController();
  final TextEditingController taiKhoanController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController matKhauController = TextEditingController();

  bool trangThai = true;
  String vaiTro = 'hocvien';
  bool get isEdit => widget.user != null;

  final String apiUrl = 'http://10.200.28.33:5000/admin/nguoidung';

  Future<void> addUser() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'hoTen': hoTenController.text,
        'taiKhoan': taiKhoanController.text,
        'email': emailController.text,
        'matKhau': matKhauController.text,
        'trangThai': trangThai,
        'vaiTro': vaiTro,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thêm user thất bại')));
    }
  }

  Future<void> updateUser() async {
    final respone = await http.put(
      Uri.parse('$apiUrl/${widget.user!['idNguoiDung']}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'hoTen': hoTenController.text,
        'taiKhoan': taiKhoanController.text,
        'email': emailController.text,
        'trangThai': trangThai,
        'vaiTro': vaiTro,
        'matKhau': matKhauController.text,
      }),
    );
    if (respone.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại')));
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.user != null) {
      hoTenController.text = widget.user!['hoTen'] ?? '';
      taiKhoanController.text = widget.user!['taiKhoan'] ?? '';
      emailController.text = widget.user!['email'] ?? '';
      matKhauController.text = widget.user!['matKhau'] ?? '';
      trangThai = widget.user!['trangThai'] ?? true;
      vaiTro = widget.user!['vaiTro'] ?? 'hocvien';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa User' : 'Thêm User')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            TextField(
              controller: hoTenController,
              decoration: const InputDecoration(labelText: 'Họ tên'),
            ),
            TextField(
              controller: taiKhoanController,
              decoration: const InputDecoration(labelText: 'Tài khoản'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: matKhauController,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: vaiTro,
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'hocvien', child: Text('Học viên')),
                DropdownMenuItem(value: 'giangvien', child: Text('Giảng viên')),
              ],
              onChanged: (value) {
                setState(() {
                  vaiTro = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Vai trò'),
            ),

            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Hoạt động'),
              value: trangThai,
              onChanged: (value) {
                setState(() {
                  trangThai = value;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (isEdit) {
                  updateUser();
                } else {
                  addUser();
                }
              },
              child: Text(isEdit ? 'Cập nhật' : 'Thêm User'),
            ),
          ],
        ),
      ),
    );
  }
}
