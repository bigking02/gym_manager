import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/payment_model.dart';

class PaymentsHistoryScreen extends StatefulWidget {
  final int memberId;

  const PaymentsHistoryScreen({
    super.key,
    required this.memberId,
  });

  @override
  State<PaymentsHistoryScreen> createState() =>
      _PaymentsHistoryScreenState();
}

class _PaymentsHistoryScreenState
    extends State<PaymentsHistoryScreen> {

List<Payment> payments = [];

@override
void initState() {
super.initState();
loadPayments();
}

Future<void> loadPayments() async {
payments = await DatabaseHelper.instance.getPayments(
widget.memberId,
);

setState(() {});
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("سجل المدفوعات"),
    ),
    body: payments.isEmpty
        ? const Center(
      child: Text(
        "لا توجد مدفوعات",
        style: TextStyle(fontSize: 18),
      ),
    )
        : ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.payments),
            ),
            title: Text("${payment.amount} جنيه"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.paymentDate),
                Text(payment.notes),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () async {
                await DatabaseHelper.instance.deletePayment(
                  payment.id!,
                );

                await loadPayments();

                if (!mounted) return;

                Navigator.pop(context, true);
              },
            ),
          ),
        );
      },
    ),
  );
}
}