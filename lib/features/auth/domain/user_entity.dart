class User {
  final String id;
  final String name;
  final String role; // 'customer', 'kitchen', 'admin'
  final String token;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'customer',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'token': token,
    };
  }
}
