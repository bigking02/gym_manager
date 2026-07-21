import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';
import '../../models/member_model.dart';
import 'member_details_screen.dart';

class ExpiredMembersScreen extends StatefulWidget {
  const ExpiredMembersScreen({super.key});

  @override
  State<ExpiredMembersScreen> createState() =>
      _ExpiredMembersScreenState();
}

class _ExpiredMembersScreenState
    extends State<ExpiredMembersScreen> {

List<Member> members = [];

@override
void initState() {
super.initState();
loadMembers();
}

Future<void> loadMembers() async {
members =
await DatabaseHelper.instance.getExpiredMembers();

setState(() {});
}
String getStatus(String endDate) {
  final end = DateFormat("dd/MM/yyyy").parse(endDate);

  final diff = end.difference(DateTime.now()).inDays;

  if (diff < 0) {
    return "🔴 منتهي منذ ${-diff} يوم";
  } else if (diff == 0) {
    return "🟠 ينتهي اليوم";
  } else if (diff == 1) {
    return "🟡 متبقي يوم";
  } else {
    return "🟢 متبقي $diff أيام";
  }
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("الاشتراكات المنتهية"),
    ),
    body: members.isEmpty
        ? const Center(
      child: Text(
        "لا توجد اشتراكات منتهية 🎉",
        style: TextStyle(fontSize: 18),
      ),
    )
        : ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(
                Icons.warning,
                color: Colors.white,
              ),
            ),
            title: Text(member.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("تاريخ الانتهاء: ${member.endDate}"),
                const SizedBox(height: 4),
                Text(
                  getStatus(member.endDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MemberDetailsScreen(
                    member: member,
                  ),
                ),
              );

              loadMembers();
            },
          ),
        );
      },
    ),
  );
}
}