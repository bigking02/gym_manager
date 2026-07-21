import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/member_model.dart';
import '../../models/payment_model.dart';

class PaymentScreen extends StatefulWidget {
  final Member member;

  const PaymentScreen({
    super.key,
    required this.member,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
List<Payment> payments = [];

final amountController = TextEditingController();
final notesController = TextEditingController();

double totalPaid = 0;

@override
void initState() {
super.initState();
loadPayments();
}

Future<void> loadPayments() async {
payments =
await DatabaseHelper.instance.getPayments(widget.member.id!);

totalPaid =
await DatabaseHelper.instance.getTotalPaid(widget.member.id!);

setState(() {});
}

Future<void> addPayment() async {
if (amountController.text.isEmpty) return;

final payment = Payment(
memberId: widget.member.id!,
amount: double.parse(amountController.text),
paymentDate:
DateTime.now().toString().substring(0, 10),
notes: notesController.text,
);

await DatabaseHelper.instance.insertPayment(payment);

amountController.clear();
notesController.clear();

loadPayments();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("تم إضافة الدفعة"),
),
);
}

@override
Widget build(BuildContext context) {
double remaining =
widget.member.price - totalPaid;

return Scaffold(
appBar: AppBar(
title: Text(widget.member.name),
),
body: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
Card(
child: ListTile(
title: Text(
"إجمالي المدفوع : ${totalPaid.toStringAsFixed(0)} جنيه",
),
subtitle: Text(
"المتبقي : ${remaining.toStringAsFixed(0)} جنيه",
),
),
),

const SizedBox(height: 20),

TextField(
controller: amountController,
keyboardType: TextInputType.number,
decoration: const InputDecoration(
labelText: "قيمة الدفعة",
border: OutlineInputBorder(),
),
),

const SizedBox(height: 15),

TextField(
controller: notesController,
decoration: const InputDecoration(
labelText: "ملاحظات",
border: OutlineInputBorder(),
),
),

const SizedBox(height: 15),

SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: addPayment,
child: const Text("إضافة دفعة"),
),
),

const SizedBox(height: 20),

const Divider(),Expanded(
    child: payments.isEmpty
        ? const Center(
      child: Text(
        "لا توجد دفعات",
        style: TextStyle(fontSize: 18),
      ),
    )
        : ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];

        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.payments,
              color: Colors.green,
            ),
            title: Text(
              "${payment.amount.toStringAsFixed(0)} جنيه",
            ),
            subtitle: Text(
              payment.paymentDate,
            ),
            trailing: payment.notes.isNotEmpty
                ? Text(payment.notes)
                : null,
          ),
        );
      },
    ),
  ),
],
),
),
);
}
}