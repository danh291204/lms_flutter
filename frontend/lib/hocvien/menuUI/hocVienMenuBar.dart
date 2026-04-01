import 'package:flutter/material.dart';

class Hocvienmenubar extends StatelessWidget {
  final String hoTen;
  final String vaiTro;

  const Hocvienmenubar({
    super.key,
    required this.hoTen,
    required this.vaiTro,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(hoTen),
            accountEmail: const Text("Hoc viên"),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.admin_panel_settings),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.class_),
            title: const Text("Trang chủ"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/homeHocVien');
            },
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Quản lý người dùng"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/thongTinHocVien');
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Đăng xuất"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}