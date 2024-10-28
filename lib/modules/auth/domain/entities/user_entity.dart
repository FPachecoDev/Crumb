// lib/features/auth/domain/entities/user_entity.dart

class UserEntity {
  final String id;
  final String email;
  final String name;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
  });
}
