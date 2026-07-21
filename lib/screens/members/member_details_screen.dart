import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/member_model.dart';
import 'add_member_screen.dart';
import '../payments/payments_history_screen.dart';
import '../../widgets/member_info_card.dart';
import '../../widgets/action_button.dart';

class MemberDetailsScreen extends StatefulWidget {
  final Member member;

  const MemberDetailsScreen({
    super.key,
    required this.member,
  });

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
late Member member;

@override
void initState() {
super.initState();
member = widget.member;
}

Future<void> refreshMember() async {
final newMember =
await DatabaseHelper.instance.getMember(member.id!);

if (newMember != null && mounted) {
setState(() {
member = newMember;
});
}
}
Future<void> renewMember() async {
  final priceController =
  TextEditingController(text: member.price.toString());

  final paidController = TextEditingController();

  int months = member.months;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("تجديد الاشتراك"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  DropdownButtonFormField<int>(
                    value: months,
                    decoration: const InputDecoration(
                      labelText: "عدد الشهور",
                    ),
                    items: List.generate(
                      12,
                          (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text("${i + 1} شهر"),
                      ),
                    ),
                    onChanged: (v) {
                      setDialogState(() {
                        months = v!;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "سعر الاشتراك",
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: paidController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "المدفوع",
                    ),
                  ),
                ],
              ),
            ),
            actions: [

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("إلغاء"),
              ),

              ElevatedButton(
                onPressed: () async {

                  double price =
                  double.parse(priceController.text);

                  double paid =
                  paidController.text.isEmpty
                      ? 0
                      : double.parse(paidController.text);

                  await DatabaseHelper.instance.renewMember(
                    memberId: member.id!,
                    months: months,
                    price: price,
                    paid: paid,
                  );

                  Navigator.pop(context);

                  await refreshMember();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم تجديد الاشتراك"),
                    ),
                  );
                },
                child: const Text("حفظ"),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> addPayment() async {
final amountController = TextEditingController();
final notesController = TextEditingController();

await showDialog(
context: context,
builder: (context) {
return AlertDialog(
title: const Text("إضافة دفعة"),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(
controller: amountController,
keyboardType: TextInputType.number,
decoration: const InputDecoration(
labelText: "قيمة الدفعة",
),
),
const SizedBox(height: 10),
TextField(
controller: notesController,
decoration: const InputDecoration(
labelText: "ملاحظات",
),
),
],
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text("إلغاء"),
),
ElevatedButton(
onPressed: () async {
if (amountController.text.isEmpty) return;

await DatabaseHelper.instance.addPaymentAndUpdateMember(
memberId: member.id!,
amount: double.parse(amountController.text),
notes: notesController.text,
);

Navigator.pop(context);

await refreshMember();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("تمت إضافة الدفعة"),
),
);
},
child: const Text("حفظ"),
),
],
);
},
);
}

Future<void> deleteMember() async {
bool? confirm = await showDialog(
context: context,
builder: (context) {
return AlertDialog(
title: const Text("تأكيد الحذف"),
content: const Text(
"هل أنت متأكد من حذف هذا المشترك؟",
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context, false),
child: const Text("إلغاء"),
),
ElevatedButton(
onPressed: () => Navigator.pop(context, true),
child: const Text("حذف"),
),
],
);
},
);

if (confirm == true) {
await DatabaseHelper.instance.deleteMember(member.id!);

if (!mounted) return;

Navigator.pop(context, true);

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("تم حذف المشترك"),
),
);
}
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("بيانات المشترك"),
    ),
    body: Padding(
      padding: const EdgeInsets.all(15),
      child: ListView(
        children: [
          MemberInfoCard(
            title: "الاسم",
            value: member.name,
          ),

          MemberInfoCard(
            title: "رقم الهاتف",
            value: member.phone,
          ),

          MemberInfoCard(
            title: "عدد الشهور",
            value: member.months.toString(),
          ),

          MemberInfoCard(
            title: "سعر الاشتراك",
            value: "${member.price} جنيه",
          ),

          MemberInfoCard(
            title: "المدفوع",
            value: "${member.paid} جنيه",
          ),

          MemberInfoCard(
            title: "المتبقي",
            value: "${member.remaining} جنيه",
          ),

          MemberInfoCard(
            title: "بداية الاشتراك",
            value: member.startDate,
          ),

          MemberInfoCard(
            title: "نهاية الاشتراك",
            value: member.endDate,
          ),

          MemberInfoCard(
            title: "ملاحظات",
            value: member.notes,
          ),

          const SizedBox(height: 25),

          ActionButton(
            title: "إضافة دفعة",
            icon: Icons.payments,
            onPressed: addPayment,
          ),
          const SizedBox(height: 10),

          ActionButton(
            title: "سجل المدفوعات",
            icon: Icons.receipt_long,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentsHistoryScreen(
                    memberId: member.id!,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          ActionButton(
            title: "تعديل البيانات",
            icon: Icons.edit,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddMemberScreen(
                    member: member,
                  ),
                ),
              );

              if (result == true) {
                await refreshMember();
              }
            },
          ),

          const SizedBox(height: 10),

          ActionButton(
            title: "تجديد الاشتراك",
            icon: Icons.refresh,
            onPressed: renewMember,
          ),
          const SizedBox(height: 10),

          ActionButton(
            title: "حذف المشترك",
            icon: Icons.delete,
            onPressed: deleteMember,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    ),
  );
}
}