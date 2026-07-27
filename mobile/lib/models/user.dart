class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String userType;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.userType,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      userType: json['user_type'] ?? '',
      createdAt: json['created_at'],
    );
  }
}
