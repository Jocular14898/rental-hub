class Reminder {
  final String id;
  final String tenantName;
  final String? tenantPhone;
  final String? unitNumber;
  final double? rentAmount;
  final String dueDate;
  final String status;
  final String? notes;
  final String? createdAt;

  Reminder({
    required this.id,
    required this.tenantName,
    this.tenantPhone,
    this.unitNumber,
    this.rentAmount,
    required this.dueDate,
    required this.status,
    this.notes,
    this.createdAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] ?? '',
      tenantName: json['tenant_name'] ?? '',
      tenantPhone: json['tenant_phone'],
      unitNumber: json['unit_number'],
      rentAmount: json['rent_amount']?.toDouble(),
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? 'unpaid',
      notes: json['notes'],
      createdAt: json['created_at'],
    );
  }
}
