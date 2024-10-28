// lib/features/auth/domain/entities/user_entity.dart

class RegisterUserEntity {
  final String email;
  final String name;
  final String surname;
  final String nickname;
  final DateTime dateOfBirth;
  final bool acceptedTerms;
  final String password;

  RegisterUserEntity({
    required this.email,
    required this.name,
    required this.surname,
    required this.nickname,
    required this.dateOfBirth,
    required this.acceptedTerms,
    required this.password,
  });
}
