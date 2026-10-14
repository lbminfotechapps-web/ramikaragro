
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/consultant_doctor_model.dart';

class ConsultantLocalDataSource {
  static const storageKey = 'consultant_doctors_dynamic_v1';

  Future<List<ConsultantDoctorModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(storageKey);

    if (stored == null || stored.isEmpty) return [];

    final decoded = jsonDecode(stored) as List<dynamic>;

    return decoded.map((item) {
      return ConsultantDoctorModel.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  Future<void> save(
    ConsultantDoctorModel model,
  ) async {
    final list = await getAll();

    final index = list.indexWhere(
      (item) => item.entity.id == model.entity.id,
    );

    if (index >= 0) {
      list[index] = model;
    } else {
      list.insert(0, model);
    }

    final prefs = await SharedPreferences.getInstance();

    final saved = await prefs.setString(
      storageKey,
      jsonEncode(
        list.map((item) => item.toJson()).toList(),
      ),
    );

    if (!saved) {
      throw Exception('Failed to save consultant');
    }
  }
}
