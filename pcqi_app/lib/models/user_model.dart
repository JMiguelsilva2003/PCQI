class UserModel {
  String? email;
  String? password;
  String? name;
  int? id;
  String? createdAt;
  String? role;
  // Machine? machines;
  String? detail;

  UserModel({
    this.email = "",
    this.password = "",
    this.name = "",
    this.id = -2,
    this.createdAt = "",
    this.role = "",
    this.detail = "",
  });

  // Converts a map to an object of this class
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? -2,
    password: json['password'] ?? '',
    email: json['email'] ?? '',
    name: json['name'] ?? '',
    role: json['role'] ?? '',
    detail: json['detail'] ?? '',
    createdAt: json['created_at'] ?? '',
  );

  // Converts an object of this class to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'password': password,
      'email': email,
      'name': name,
      'role': role,
      'detail': detail,
      'created_at': createdAt,
    };
  }
}
