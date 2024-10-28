// lib/features/auth/data/repositories/auth_repository_impl.dart

import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserModel> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<void> logout() async {
    return await remoteDataSource.removeUserId();
  }

  @override
  Future<UserModel> register(
    String email,
    String password,
    String name,
    String surname,
    String nickname,
    bool acceptedTerms,
    DateTime dateOfBirth, // Agora corresponde à interface
  ) async {
    return await remoteDataSource.register(
      email: email,
      password: password,
      name: name,
      surname: surname,
      nickname: nickname,
      acceptedTerms: acceptedTerms,
      dateOfBirth: dateOfBirth, // Passando dateOfBirth para o remoteDataSource
    );
  }
}
