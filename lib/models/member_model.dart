class Member {
  final int? id;
  final String name;
  final String phone;
  final int months;
  final double price;
  final double paid;
  final double remaining;
  final String startDate;
  final String endDate;
  final String notes;

  Member({
    this.id,
    required this.name,
    required this.phone,
    required this.months,
    required this.price,
    required this.paid,
    required this.remaining,
    required this.startDate,
    required this.endDate,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'months': months,
      'price': price,
      'paid': paid,
      'remaining': remaining,
      'startDate': startDate,
      'endDate': endDate,
      'notes': notes,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      months: map['months'],
      price: (map['price'] as num).toDouble(),
      paid: (map['paid'] as num).toDouble(),
      remaining: (map['remaining'] as num).toDouble(),
      startDate: map['startDate'],
      endDate: map['endDate'],
      notes: map['notes'] ?? '',
    );
  }
  Member copyWith({
    int? id,
    String? name,
    String? phone,
    int? months,
    double? price,
    double? paid,
    double? remaining,
    String? startDate,
    String? endDate,
    String? notes,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      months: months ?? this.months,
      price: price ?? this.price,
      paid: paid ?? this.paid,
      remaining: remaining ?? this.remaining,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
    );
  }
}