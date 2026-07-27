import 'property.dart';

class Booking {
  final String id;
  final String tenantId;
  final String propertyId;
  final String status;
  final String? message;
  final Property? property;
  final String? createdAt;

  Booking({
    required this.id,
    required this.tenantId,
    required this.propertyId,
    required this.status,
    this.message,
    this.property,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      tenantId: json['tenant_id'] ?? '',
      propertyId: json['property_id'] ?? '',
      status: json['status'] ?? 'pending',
      message: json['message'],
      property: json['property'] != null
          ? Property.fromJson(json['property'])
          : null,
      createdAt: json['created_at'],
    );
  }
}
