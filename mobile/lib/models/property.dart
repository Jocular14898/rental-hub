class PropertyPhoto {
  final String id;
  final String url;
  final bool isPrimary;

  PropertyPhoto({required this.id, required this.url, required this.isPrimary});

  factory PropertyPhoto.fromJson(Map<String, dynamic> json) {
    return PropertyPhoto(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      isPrimary: json['is_primary'] ?? false,
    );
  }
}

class Property {
  final String id;
  final String landlordId;
  final String title;
  final double price;
  final String location;
  final double? latitude;
  final double? longitude;
  final int bedrooms;
  final String? houseType;
  final String? description;
  final String? securityDetails;
  final bool parking;
  final bool waterAvailable;
  final String contactPhone;
  final bool isActive;
  final List<PropertyPhoto> photos;
  final String? createdAt;

  Property({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.price,
    required this.location,
    this.latitude,
    this.longitude,
    required this.bedrooms,
    this.houseType,
    this.description,
    this.securityDetails,
    required this.parking,
    required this.waterAvailable,
    required this.contactPhone,
    required this.isActive,
    required this.photos,
    this.createdAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      landlordId: json['landlord_id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      bedrooms: json['bedrooms'] ?? 0,
      houseType: json['house_type'],
      description: json['description'],
      securityDetails: json['security_details'],
      parking: json['parking'] ?? false,
      waterAvailable: json['water_available'] ?? false,
      contactPhone: json['contact_phone'] ?? '',
      isActive: json['is_active'] ?? true,
      photos: (json['photos'] as List?)
              ?.map((p) => PropertyPhoto.fromJson(p))
              .toList() ??
          [],
      createdAt: json['created_at'],
    );
  }

  String get photoUrl =>
      photos.isNotEmpty ? photos.first.url : '';
}
