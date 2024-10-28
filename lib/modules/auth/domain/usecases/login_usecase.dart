// lib/features/auth/domain/usecases/login_usecase.dart

import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';
import '../../data/models/user_model.dart'; // Adicione essa importação

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase({required this.authRepository});

  Future<UserEntity> call(String email, String password) async {
    // Chama o repositório para realizar o login
    UserModel userModel = await authRepository.login(email, password);

    // Converte UserModel para UserEntity
    return UserEntity(
      id: userModel.id,
      email: userModel.email,
      name: userModel.name,
    );
  }
}
