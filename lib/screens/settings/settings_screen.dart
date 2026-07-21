import 'package:flutter/material.dart';

import '../../services/backup_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backup = BackupService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.backup),
                label: const Text("إنشاء نسخة احتياطية"),
                onPressed: () async {
                  final success = await backup.createBackup();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? "تم فتح نافذة مشاركة النسخة الاحتياطية"
                            : "فشل إنشاء النسخة الاحتياطية",
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.restore),
                label: const Text("استرجاع نسخة احتياطية"),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("استرجاع نسخة احتياطية"),
                        content: const Text(
                          "سيتم استبدال جميع البيانات الحالية بالبيانات الموجودة داخل النسخة الاحتياطية.\n\nهل تريد المتابعة؟",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text("إلغاء"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text("استرجاع"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm != true) return;

                  final ok = await backup.restoreBackup();

                  if (!context.mounted) return;

                  if (ok) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("تم استرجاع النسخة الاحتياطية بنجاح ✅"),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("فشل استرجاع النسخة الاحتياطية"),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}