class Payment {
  final int? id;
  final int memberId;
  final double amount;
  final String paymentDate;
  final String notes;

  Payment({
    this.id,
    required this.memberId,
    required this.amount,
    required this.paymentDate,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'amount': amount,
      'paymentDate': paymentDate,
      'notes': notes,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      memberId: map['memberId'],
      amount: (map['amount'] as num).toDouble(),
      paymentDate: map['paymentDate'],
      notes: map['notes'] ?? '',
    );
  }
}