// lib/features/auth/domain/usecases/logout_usecase.dart

import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository authRepository;

  LogoutUseCase({required this.authRepository});

  Future<void> call() async {
    await authRepository.logout();
  }
}
