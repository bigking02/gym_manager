import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database_helper.dart';
import '../../models/member_model.dart';
import '../../models/payment_model.dart';

class AddMemberScreen extends StatefulWidget {
  final Member? member;

  const AddMemberScreen({
    super.key,
    this.member,
  });

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {

  @override
  void initState() {
    super.initState();

    if (widget.member != null) {
      final m = widget.member!;

      nameController.text = m.name;
      phoneController.text = m.phone;
      priceController.text = m.price.toString();
      paidController.text = m.paid.toString();
      notesController.text = m.notes;

      months = m.months;
      remaining = m.remaining;

      startDate = DateFormat("dd/MM/yyyy").parse(m.startDate);
    }
  }
final _formKey = GlobalKey<FormState>();

final nameController = TextEditingController();
final phoneController = TextEditingController();
final priceController = TextEditingController();
final paidController = TextEditingController();
final notesController = TextEditingController();

DateTime startDate = DateTime.now();

int months = 1;

double remaining = 0;

String get endDate {

DateTime end = DateTime(
startDate.year,
startDate.month + months,
startDate.day,
);

return DateFormat(
"dd/MM/yyyy",
).format(end);

}

void calculateRemaining() {

double price =
double.tryParse(priceController.text) ?? 0;

double paid =
double.tryParse(paidController.text) ?? 0;

setState(() {

remaining = price - paid;

if (remaining < 0) {
remaining = 0;
}

});

}

Future<void> pickDate() async {

DateTime? picked =
await showDatePicker(

context: context,

initialDate: startDate,

firstDate: DateTime(2020),

lastDate: DateTime(2100),

);

if (picked != null) {

setState(() {

startDate = picked;

});

}

}

Future<void> saveMember() async {
try {
if (!_formKey.currentState!.validate()) {
return;

}

double price =
double.parse(priceController.text);

double paid =
double.parse(paidController.text);

final member = Member(

name: nameController.text,

phone: phoneController.text,

months: months,

price: price,

paid: paid,

remaining: remaining,

startDate: DateFormat(
"dd/MM/yyyy",
).format(startDate),

endDate: endDate,

notes: notesController.text,

);

if (widget.member == null) {

  int memberId =
  await DatabaseHelper.instance.insertMember(member);

  await DatabaseHelper.instance.insertPayment(
    Payment(
      memberId: memberId,
      amount: paid,
      paymentDate: DateFormat("dd/MM/yyyy")
          .format(DateTime.now()),
      notes: "أول دفعة",
    ),
  );

} else {

  await DatabaseHelper.instance.updateMember(
    member.copyWith(
      id: widget.member!.id,
    ),
  );

}

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text("تم حفظ المشترك بنجاح"),
    duration: Duration(seconds: 2),
  ),
);

await Future.delayed(const Duration(seconds: 2));

if (mounted) {
  Navigator.pop(context, true);
}
} catch (e, s) {
  print(e);
  print(s);

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  }
}
}

@override
void dispose() {

nameController.dispose();
phoneController.dispose();
priceController.dispose();
paidController.dispose();
notesController.dispose();

super.dispose();

}

@override
Widget build(BuildContext context) {

return Scaffold(

appBar: AppBar(

  title: Text(
    widget.member == null
        ? "إضافة مشترك"
        : "تعديل بيانات المشترك",
  ),

),

body: Form(

key: _formKey,

child: SingleChildScrollView(

padding: const EdgeInsets.all(16),

child: Column(

children: [TextFormField(
controller: nameController,
decoration: const InputDecoration(
labelText: "اسم المشترك",
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.person),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "أدخل اسم المشترك";
}
return null;
},
),

const SizedBox(height: 15),

TextFormField(
controller: phoneController,
keyboardType: TextInputType.phone,
decoration: const InputDecoration(
labelText: "رقم الهاتف",
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.phone),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "أدخل رقم الهاتف";
}
return null;
},
),

const SizedBox(height: 15),

ListTile(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(8),
side: const BorderSide(color: Colors.grey),
),
title: Text(
"تاريخ البداية : ${DateFormat("dd/MM/yyyy").format(startDate)}",
),
trailing: const Icon(Icons.calendar_month),
onTap: pickDate,
),

const SizedBox(height: 15),

DropdownButtonFormField<int>(
value: months,
decoration: const InputDecoration(
labelText: "عدد الشهور",
border: OutlineInputBorder(),
),
items: List.generate(
12,
(index) => DropdownMenuItem(
value: index + 1,
child: Text("${index + 1} شهر"),
),
),
onChanged: (value) {
setState(() {
months = value!;
});
},
),

const SizedBox(height: 15),

TextFormField(
controller: priceController,
keyboardType: TextInputType.number,
decoration: const InputDecoration(
labelText: "سعر الاشتراك",
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.attach_money),
),
onChanged: (_) => calculateRemaining(),
validator: (value) {
if (value == null ||
double.tryParse(value) == null) {
return "أدخل سعر صحيح";
}
return null;
},
),

const SizedBox(height: 15),

TextFormField(
controller: paidController,
keyboardType: TextInputType.number,
decoration: const InputDecoration(
labelText: "المدفوع",
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.payments),
),
onChanged: (_) => calculateRemaining(),
validator: (value) {
if (value == null ||
double.tryParse(value) == null) {
return "أدخل المبلغ المدفوع";
}
return null;
},
),

const SizedBox(height: 20),

Card(
child: ListTile(leading: const Icon(Icons.calculate),
  title: Text(
    "المتبقي : ${remaining.toStringAsFixed(0)} جنيه",
  ),
  subtitle: Text(
    "ينتهي الاشتراك في : $endDate",
  ),
),
),

  const SizedBox(height: 15),

  TextFormField(
    controller: notesController,
    maxLines: 3,
    decoration: const InputDecoration(
      labelText: "ملاحظات",
      border: OutlineInputBorder(),
    ),
  ),

  const SizedBox(height: 30),

  SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton.icon(
      onPressed: saveMember,
      icon: const Icon(Icons.save),
      label: const Text(
        "حفظ المشترك",
        style: TextStyle(fontSize: 18),
      ),
    ),
  ),

],
),
),
),
);
}
}