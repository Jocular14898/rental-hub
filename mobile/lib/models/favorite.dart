import 'property.dart';

class Favorite {
  final String id;
  final String userId;
  final String propertyId;
  final Property? property;
  final String? createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.propertyId,
    this.property,
    this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      propertyId: json['property_id'] ?? '',
      property: json['property'] != null
          ? Property.fromJson(json['property'])
          : null,
      createdAt: json['created_at'],
    );
  }
}
