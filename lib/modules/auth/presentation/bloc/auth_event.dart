// lib/features/auth/presentation/bloc/auth_event.dart

abstract class AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String surname;
  final String nickname;
  final bool acceptedTerms;
  final DateTime dateOfBirth; // Certifique-se de que o tipo está correto

  RegisterEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.surname,
    required this.nickname,
    required this.acceptedTerms,
    required this.dateOfBirth,
  });
}

class LogoutEvent extends AuthEvent {}
