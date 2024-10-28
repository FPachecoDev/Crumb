// lib/features/auth/domain/usecases/login_usecase.dart

import 'package:crumb/modules/auth/domain/entities/user_register_entity.dart';

import '../repositories/auth_repository.dart';

import '../../data/models/user_model.dart'; // Adicione essa importação

class RegisterUseCase {
  final AuthRepository authRepository;

  RegisterUseCase({required this.authRepository});

  Future<RegisterUserEntity> call(
      String email,
      String password,
      String name,
      String surname,
      String nickname,
      bool acceptedTerms,
      DateTime dateOfBirth) async {
    // Chama o repositório para realizar o login
    UserModel userModel = await authRepository.register(
        email, password, name, surname, nickname, acceptedTerms, dateOfBirth);

    // Converte UserModel para UserEntity
    return RegisterUserEntity(
        email: userModel.email,
        name: userModel.name,
        surname: userModel.surname,
        nickname: userModel.nickname,
        dateOfBirth: userModel.dateOfBirth,
        acceptedTerms: userModel.acceptedTerms,
        password: userModel.password);
  }
}
