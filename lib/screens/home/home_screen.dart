import 'package:flutter/material.dart';
import '../members/add_member_screen.dart';
import '../members/member_list_screen.dart';
import '../members/expired_members_screen.dart';
import '../settings/settings_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  Widget buildButton(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gym Manager"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [

            buildButton(
              context,
              "إضافة مشترك",
              Icons.person_add,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMemberScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            buildButton(
              context,
              "قائمة المشتركين",
              Icons.people,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MembersListScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            buildButton(
              context,
              "الاشتراكات المنتهية",
              Icons.notifications_active,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExpiredMembersScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),

            buildButton(
              context,
              "الإعدادات",
              Icons.settings,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}