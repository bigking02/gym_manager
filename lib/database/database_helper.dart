import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../models/member_model.dart';
import '../models/payment_model.dart';

class DatabaseHelper {

DatabaseHelper._internal();
static final DatabaseHelper instance = DatabaseHelper._internal();

static Database? _database;

Future<Database> get database async {
if (_database != null) return _database!;

_database = await _initDatabase();
return _database!;
}

Future<Database> _initDatabase() async {
final dbPath = await getDatabasesPath();

final path = join(
dbPath,
"gym_manager.db",
);

return await openDatabase(
path,
version: 1,
onCreate: _onCreate,
);
}

Future<void> _onCreate(
Database db,
int version,
) async {
await db.execute('''
CREATE TABLE members(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
phone TEXT NOT NULL,
months INTEGER NOT NULL,
price REAL NOT NULL,
paid REAL NOT NULL,
remaining REAL NOT NULL,
startDate TEXT NOT NULL,
endDate TEXT NOT NULL,
notes TEXT
)
''');

await db.execute('''
CREATE TABLE payments(
id INTEGER PRIMARY KEY AUTOINCREMENT,
memberId INTEGER NOT NULL,
amount REAL NOT NULL,
paymentDate TEXT NOT NULL,
notes TEXT
)
''');
}

//==============================
// Members
//==============================

Future<int> insertMember(
Member member,
) async {
final db = await database;

return await db.insert(
"members",
member.toMap(),
);
}

Future<List<Member>> getMembers() async {
final db = await database;

final result = await db.query(
"members",
orderBy: "name ASC",
);

return result
.map(
(e) => Member.fromMap(e),
)
.toList();
}

Future<Member?> getMember(
int id,
) async {
final db = await database;

final result = await db.query(
"members",
where: "id = ?",
whereArgs: [id],
);

if (result.isEmpty) {
return null;
}

return Member.fromMap(
result.first,
);
}

Future<int> updateMember(
Member member,
) async {
final db = await database;

return await db.update(
"members",
member.toMap(),
where: "id = ?",
whereArgs: [member.id],
);
}

Future<int> deleteMember(
int id,
) async {
final db = await database;

await db.delete(
"payments",
where: "memberId = ?",
whereArgs: [id],
);

return await db.delete(
"members",
where: "id = ?",
whereArgs: [id],
);
}
//==============================
  // Payments
  //==============================

  Future<int> insertPayment(
      Payment payment,
      ) async {
    final db = await database;

    return await db.insert(
      "payments",
      payment.toMap(),
    );
  }

  Future<List<Payment>> getPayments(
      int memberId,
      ) async {
    final db = await database;

    final result = await db.query(
      "payments",
      where: "memberId = ?",
      whereArgs: [memberId],
      orderBy: "paymentDate DESC",
    );

    return result
        .map(
          (e) => Payment.fromMap(e),
    )
        .toList();
  }

  Future<double> getTotalPaid(
      int memberId,
      ) async {
    final payments = await getPayments(memberId);

    double total = 0;

    for (final payment in payments) {
      total += payment.amount;
    }

    return total;
  }

  Future<void> deletePayment(int paymentId) async {
    final db = await database;

    final result = await db.query(
      "payments",
      where: "id = ?",
      whereArgs: [paymentId],
    );

    if (result.isEmpty) return;

    final payment = result.first;

    final int memberId = payment["memberId"] as int;
    final double amount = (payment["amount"] as num).toDouble();

    await db.delete(
      "payments",
      where: "id = ?",
      whereArgs: [paymentId],
    );

    final memberResult = await db.query(
      "members",
      where: "id = ?",
      whereArgs: [memberId],
    );

    if (memberResult.isEmpty) return;

    final member = memberResult.first;

    double paid = (member["paid"] as num).toDouble();
    double price = (member["price"] as num).toDouble();

    paid -= amount;

    if (paid < 0) {
      paid = 0;
    }

    double remaining = price - paid;

    if (remaining < 0) {
      remaining = 0;
    }

    await db.update(
      "members",
      {
        "paid": paid,
        "remaining": remaining,
      },
      where: "id = ?",
      whereArgs: [memberId],
    );
  }

  //==============================
  // Statistics
  //==============================

  Future<int> getMembersCount() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM members',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      "gym_manager.db",
    );

    await deleteDatabase(path);

    _database = null;
  }
  Future<void> addPaymentAndUpdateMember({
    required int memberId,
    required double amount,
    required String notes,
  }) async {
    final db = await database;

    // إضافة الدفعة
    await db.insert(
      "payments",
      {
        "memberId": memberId,
        "amount": amount,
        "paymentDate": DateTime.now().toString().substring(0, 10),
        "notes": notes,
      },
    );

    // جلب بيانات المشترك
    final result = await db.query(
      "members",
      where: "id = ?",
      whereArgs: [memberId],
    );

    if (result.isNotEmpty) {
      final member = result.first;

      double paid = (member["paid"] as num).toDouble();
      double price = (member["price"] as num).toDouble();

      paid += amount;

      double remaining = price - paid;
      if (remaining < 0) remaining = 0;

      await db.update(
        "members",
        {
          "paid": paid,
          "remaining": remaining,
        },
        where: "id = ?",
        whereArgs: [memberId],
      );
    }
  }
  Future<void> renewMember({
    required int memberId,
    required int months,
    required double price,
    required double paid,
  }) async {

    final db = await database;

    final result = await db.query(
      "members",
      where: "id = ?",
      whereArgs: [memberId],
    );

    if (result.isEmpty) return;

    final member = result.first;

    final DateTime start = DateTime.now();

    final DateTime end = DateTime(
      start.year,
      start.month + months,
      start.day,
    );

    final remaining = price - paid;

    await db.update(
      "members",
      {
        "months": months,
        "price": price,
        "paid": paid,
        "remaining": remaining,
        "startDate":
        "${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}",
        "endDate":
        "${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}",
      },
      where: "id = ?",
      whereArgs: [memberId],
    );

    if (paid > 0) {
      await db.insert(
        "payments",
        {
          "memberId": memberId,
          "amount": paid,
          "paymentDate":
          "${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}",
          "notes": "تجديد الاشتراك",
        },
      );
    }
  }
  Future<List<Member>> getExpiredMembers() async {
    final db = await database;

    final result = await db.query("members");

    List<Member> expired = [];

    final now = DateTime.now();
    final formatter = DateFormat("dd/MM/yyyy");

    for (final item in result) {
      final member = Member.fromMap(item);

      try {
        final endDate = formatter.parse(member.endDate);

        final difference = endDate.difference(now).inDays;

        if (difference <= 3) {
          expired.add(member);
        }
      } catch (_) {
        // تجاهل أي تاريخ غير صالح
      }
    }

    return expired;
  }
  Future<void> reopenDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await database;
  }
  Future close() async {
    final db = await database;

    db.close();
  }
}
