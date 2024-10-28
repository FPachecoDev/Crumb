import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String surname;
  final String nickname;
  final String avatarUrl;
  final String backgroundUrl;
  final DateTime dateOfBirth;
  final bool acceptedTerms;
  final DateTime createdAt;
  final String password;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.nickname,
    required this.avatarUrl,
    required this.backgroundUrl,
    required this.dateOfBirth,
    required this.acceptedTerms,
    required this.createdAt,
    required this.password,
  });

  // Método para criar uma instância de UserModel a partir de um Map
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      id: uid,
      password: map['password'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      nickname: map['nickname'] as String,
      avatarUrl: map['avatarUrl'] as String? ?? '',
      backgroundUrl: map['backgroundUrl'] as String? ?? '',
      dateOfBirth: map['dateOfBirth'] is Timestamp
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : DateTime(2000, 1, 1), // Valor padrão ou lógica alternativa
      acceptedTerms: map['acceptedTerms'] as bool? ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'surname': surname,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'backgroundUrl': backgroundUrl,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'acceptedTerms': acceptedTerms,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
