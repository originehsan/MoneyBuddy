// MoneyBuddy
import 'user_model.dart';

/// Maps the raw signin API response to typed Dart objects.
class AuthResponseModel {
  final String token;
  final UserModel? data;

  const AuthResponseModel({
    required this.token,
    this.data,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String? ?? '',
      data: json['data'] != null
          ? UserModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}