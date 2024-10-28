// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:crumb/modules/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel> register(
    String email,
    String password,
    String name,
    String surname,
    String nickname,
    bool acceptedTerms,
    DateTime dateOfBirth, // Adicionado parâmetro dateOfBirth
  );
}
