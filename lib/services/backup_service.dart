import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';

class BackupService {  Future<bool> createBackup() async {
  try {
    final dbFolder = await getDatabasesPath();

    final dbPath = join(
      dbFolder,
      "gym_manager.db",
    );

    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      return false;
    }

    final tempDir = await getTemporaryDirectory();

    final backupFile = File(
      join(tempDir.path, "gym_backup.db"),
    );

    if (await backupFile.exists()) {
      await backupFile.delete();
    }
    await DatabaseHelper.instance.close();

    await dbFile.copy(backupFile.path);

    await DatabaseHelper.instance.reopenDatabase();

    await Share.shareXFiles(
      [XFile(backupFile.path)],
      text: "النسخة الاحتياطية لبرنامج Gym Manager",
    );

    return true;
  } catch (e) {
    print(e);
    return false;
  }
}
Future<bool> restoreBackup() async {
try {
FilePickerResult? result =
await FilePicker.platform.pickFiles();

if (result == null) {
return false;
}

final selectedFile = File(result.files.single.path!);

final dbFolder = await getDatabasesPath();

final dbPath = join(
dbFolder,
"gym_manager.db",
);

// اقفل قاعدة البيانات قبل الاستبدال
await DatabaseHelper.instance.close();

final currentDb = File(dbPath);

if (await currentDb.exists()) {
await currentDb.delete();
}

// انسخ النسخة الاحتياطية
await selectedFile.copy(dbPath);

// افتح قاعدة البيانات من جديد
await DatabaseHelper.instance.reopenDatabase();

return true;
} catch (e) {
print(e);
return false;
}
}
}