import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';

class TaskLocalDataSource {
  static const String storageKey = 'assigned_tasks_v2';

  Future<List<TaskModel>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);

    if (decoded is! List) {
      throw const FormatException('Invalid stored task list');
    }

    return decoded.map((item) {
      return TaskModel.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();

    final saved = await prefs.setString(
      storageKey,
      jsonEncode(tasks.map((e) => e.toJson()).toList()),
    );

    if (!saved) {
      throw Exception('Unable to save task data');
    }
  }
}
