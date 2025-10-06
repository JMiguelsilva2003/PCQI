import 'package:pcqi_app/models/machine_model.dart';
import 'package:pcqi_app/models/sector_model.dart';

class UserModel {
  String? email;
  String? password;
  String? name;
  int? id;
  String? createdAt;
  String? role;
  List<MachineModel> machines;
  List<SectorModel> sectors;
  String? detail;
  String? message;
  String? accessToken;
  String? refreshToken;
  String tokenType;

  UserModel({
    this.email = "",
    this.password = "",
    this.name = "",
    this.id = -2,
    this.createdAt = "",
    this.role = "",
    this.machines = const [],
    this.sectors = const [],
    this.detail = "",
    this.message = "",
    this.accessToken = "",
    this.refreshToken = "",
    this.tokenType = "",
  });

  // Converts a map to an object of this class
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? -2,
    password: json['password'] ?? '',
    email: json['email'] ?? '',
    name: json['name'] ?? '',
    role: json['role'] ?? '',
    machines: json['machines'] ?? [],
    sectors: json['sectors'] ?? [],
    detail: json['detail'] ?? '',
    message: json['message'] ?? '',
    createdAt: json['created_at'] ?? '',
    accessToken: json['access_token'] ?? '',
    refreshToken: json['refresh_token'] ?? '',
    tokenType: json['token_type'] ?? '',
  );

  // Converts an object of this class to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'password': password,
      'email': email,
      'name': name,
      'role': role,
      // machine field is missing by now
      // sectors field is missing by now
      'detail': detail,
      'message': message,
      'created_at': createdAt,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
    };
  }
}
