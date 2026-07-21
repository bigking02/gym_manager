import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/member_model.dart';
import 'member_details_screen.dart';

class MembersListScreen extends StatefulWidget {
  const MembersListScreen({super.key});

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  List<Member> members = [];
  List<Member> filteredMembers = [];

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> loadMembers() async {
    final data = await DatabaseHelper.instance.getMembers();

    setState(() {
      members = data;
      filteredMembers = data;
    });
  }

  void search(String value) {
    setState(() {
      filteredMembers = members.where((member) {
        return member.name
            .toLowerCase()
            .contains(value.toLowerCase()) ||
            member.phone.contains(value);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("قائمة المشتركين"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "ابحث بالاسم أو رقم الهاتف",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: search,
            ),
          ),
          Expanded(
            child: filteredMembers.isEmpty
                ? const Center(
              child: Text(
                "لا يوجد مشتركين",
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                final member = filteredMembers[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MemberDetailsScreen(member: member),
                        ),
                      );

                      await loadMembers();

                      if (mounted) {
                        setState(() {});
                      }
                    },
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(member.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.phone),
                        Text("الاشتراك: ${member.months} شهر"),
                        Text("المدفوع: ${member.paid} جنيه"),
                        Text("المتبقي: ${member.remaining} جنيه"),
                        Text("ينتهي: ${member.endDate}"),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}