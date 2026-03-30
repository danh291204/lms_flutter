import 'package:flutter/material.dart';
import 'package:frontend/admin/users/usersScreen.dart';
import 'package:frontend/authentication/loginScreen.dart';
import 'package:frontend/admin/menuUI/adminMenuBar.dart';
import 'package:frontend/admin/classroom/classScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LMS',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'LMS Home Page'),
        '/admin': (context) => UsersScreen(),
        '/users': (context) => UsersScreen(),
        '/classroom': (context) => ClassScreen(),
        '/login': (context) => Loginscreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void goToUsersScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UsersScreen()),
    );
  }

  void goToLoginScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Loginscreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Trang chủ'),
            ElevatedButton(
              onPressed: () {
                goToLoginScreen(context);
              },
              child: const Text('Đi tới Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
