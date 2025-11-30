// ignore_for_file: avoid_print

import 'package:hive/hive.dart';
import 'project_model.dart';

class ProjectDB {
  static const String boxName = 'project_db';

  static Future<void> addProject(ProjectModel project) async {
    final box = await Hive.openBox<ProjectModel>(boxName);
    await box.add(project);
  }

  static Future<List<ProjectModel>> getAllProjects() async {
    final box = await Hive.openBox<ProjectModel>(boxName);
    final List<ProjectModel> projects = [];
    // Iterasi melalui semua kunci di dalam box
    for (var key in box.keys) {
      try {
        // Coba ambil dan tambahkan proyek ke daftar
        final project = box.get(key);
        if (project != null) {
          projects.add(project);
        }
      } catch (e) {
        // Jika terjadi error saat membaca (deserialization), cetak pesan dan lanjutkan
        print('Error reading project with key $key: $e');
      }
    }
    return projects;
  }

  static Future<Map<dynamic, ProjectModel>> getAllProjectsWithKeys() async {
    final box = await Hive.openBox<ProjectModel>(boxName);
    // Mengembalikan map dari semua entri (key dan value)
    return box.toMap();
  }

  static Future<void> updateProject(dynamic key, ProjectModel project) async {
    final box = await Hive.openBox<ProjectModel>(boxName);
    await box.put(key, project);
  }

  static Future<void> deleteProject(dynamic key) async {
    final box = await Hive.openBox<ProjectModel>(boxName);
    await box.delete(key);
  }
}
