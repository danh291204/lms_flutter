import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/api.dart';
import 'package:frontend/giangvien/menuUI/giangVienMenuBar.dart';
import 'package:frontend/giangvien/baikiemtra/addBaiKiemTraGVScreen.dart';
import 'cauHoiGVScreen.dart';

class Baikiemtragvscreen extends StatefulWidget {
  final int idKhoaHoc;
  const Baikiemtragvscreen({super.key, required this.idKhoaHoc});

  @override
  State<Baikiemtragvscreen> createState() => _BaikiemtragvscreenState();
}

class _BaikiemtragvscreenState extends State<Baikiemtragvscreen> {
  List quizzes = [];
  bool isLoading = true;

  final String apiUrl = '${ApiConfig.baseUrl}/giangvien/quiz';

  @override
  void initState() {
    super.initState();
    fetchQuiz();
  }

  Future<void> fetchQuiz() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");

      final res = await http.get(
        Uri.parse('$apiUrl/${widget.idKhoaHoc}'),
        headers: {
          "Content-Type": "application/json",
          "x-user-id": userId.toString(),
        },
      );
      final data = jsonDecode(res.body);
      if (data["success"]) {
        setState(() {
          quizzes = data["data"];
        });
      }
    } catch (e) {
      debugPrint("Lỗi fetch quiz: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  Future<void> deleteQuiz(int idQuiz) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");
    final res = await http.delete(
      Uri.parse('$apiUrl/$idQuiz'),
      headers: {
        "Content-Type": "application/json",
        "x-user-id": userId.toString(),
      },
    );
    final data = jsonDecode(res.body);

    if (data["success"]) {
      fetchQuiz();
    }
  }

  void confirmDelete(int idQuiz) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc muốn xoá bài kiểm tra?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Huỷ"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteQuiz(idQuiz);
            },
            child: const Text("Xoá"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bài kiểm tra"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddBaiKiemTraGVScreen(
                idKhoaHoc: widget.idKhoaHoc,
              ),
            ),
          );
          fetchQuiz();
        },
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchQuiz,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Danh sách bài kiểm tra",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Quản lý quiz của lớp",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        "DANH SÁCH QUIZ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = quizzes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 1,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor:
                                  Colors.blue.withOpacity(0.1),
                              child: const Icon(Icons.quiz,
                                  color: Colors.blue),
                            ),
                            title: Text(
                              quiz["tenQuiz"] ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Thời gian: ${quiz["thoiGianLamBai"] ?? 0} phút"),
                                Text(
                                    "Số câu: ${quiz["quiz_questions"]?.length ?? 0}"),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddBaiKiemTraGVScreen(
                                    quiz: quiz,
                                    idKhoaHoc: widget.idKhoaHoc,
                                  ),
                                ),
                              );
                              fetchQuiz();
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.list_alt,
                                      color: Colors.orange),
                                  onPressed: () {
                                     Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Cauhoigvscreen(
                                          quiz: quiz,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      confirmDelete(quiz["idQuiz"]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }
}