import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/api.dart';

class QlDiemGVScreen extends StatefulWidget {
  final int idKhoaHoc;

  const QlDiemGVScreen({super.key, required this.idKhoaHoc});

  @override
  State<QlDiemGVScreen> createState() => _QlDiemGVScreenState();
}

class _QlDiemGVScreenState extends State<QlDiemGVScreen> {
  List quizzes = [];
  List list = [];

  bool isLoading = true;
  int? selectedQuiz;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    loadQuiz();
  }

  Future<void> loadQuiz() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");

      final res = await http.get(
        Uri.parse('$baseUrl/giangvien/quiz/${widget.idKhoaHoc}'),
        headers: {"x-user-id": userId.toString()},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          quizzes = data['data'] ?? [];

          if (quizzes.isNotEmpty) {
            selectedQuiz = quizzes[0]['idQuiz'];
          }
        });

        if (selectedQuiz != null) {
          loadDiem(selectedQuiz!);
        }
      }
    } catch (e) {
      debugPrint("Lỗi load quiz: $e");
    }
  }

  Future<void> loadDiem(int idQuiz) async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");
      final res = await http.get(
        Uri.parse('$baseUrl/giangvien/quiz/diemhv/$idQuiz'),
        headers: {"x-user-id": userId.toString()},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          list = data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Lỗi load điểm: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color getColor(diem) {
    if (diem == null) return Colors.grey;
    if (diem >= 8) return Colors.green;
    if (diem >= 5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Điểm bài kiểm tra"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<int>(
              value: selectedQuiz,
              decoration: const InputDecoration(
                labelText: "Chọn bài kiểm tra",
                border: OutlineInputBorder(),
              ),
              items: quizzes.map<DropdownMenuItem<int>>((q) {
                return DropdownMenuItem(
                  value: q['idQuiz'],
                  child: Text(q['tenQuiz'] ?? "Quiz"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedQuiz = value;
                });
                if (value != null) {
                  loadDiem(value);
                }
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                    ? const Center(child: Text("Chưa có dữ liệu"))
                    : RefreshIndicator(
                        onRefresh: () => loadDiem(selectedQuiz!),
                        child: ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final item = list[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text("${index + 1}"),
                                ),
                                title: Text(
                                  item['hoTen'] ?? "",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(item['email'] ?? ""),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item['diemSo'] != null
                                          ? "${item['diemSo']}"
                                          : "Chưa làm",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: getColor(item['diemSo']),
                                      ),
                                    ),
                                    Text(item['trangThai'] ?? ""),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          )
        ],
      ),
    );
  }
}