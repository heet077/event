class UserModel {
  final int? id;
  final String username;
  final String role;
  final String? email;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.role,
    this.email,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'role': role,
    };
  }
}

// If you're registering a new user with password:
Map<String, dynamic> registrationPayload({
  required String username,
  required String email,
  required String password,
  required String role,
}) {
  return {
    'username': username,
    'email': email,
    'password': password,
    'role': role,
  };
}
