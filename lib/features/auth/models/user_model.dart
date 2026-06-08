// MoneyBuddy

/// Represents the authenticated user returned by signin response.
class UserModel {
  final String id;
  final String name;
  final String email;
  final List<String> groups;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.groups,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:     json['id']    as String? ?? '',
      name:   json['name']  as String? ?? '',
      email:  json['email'] as String? ?? '',
      groups: (json['groups'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
    );
  }
}