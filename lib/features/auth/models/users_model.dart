// lib/models/user_model.dart
class UserModel {
  String id;
  final String name;
  final String surname;
  final String nickname;
  final String email;
  final String password;
  final String dateOfBirth; // Novo campo para Data de Nascimento
  final bool acceptedTerms;
  final String? avatarUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.nickname,
    required this.email,
    required this.password,
    required this.dateOfBirth,
    required this.acceptedTerms,
    this.avatarUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'nickname': nickname,
      'email': email,
      'password': password,
      'dateOfBirth': dateOfBirth,
      'acceptedTerms': acceptedTerms,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
