import '../../domain/entities/user_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoggedIn extends AuthState {
  final UserEntity user;

  AuthLoggedIn({required this.user});
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}

class AuthAuthenticated extends AuthState {
  final String userId;

  AuthAuthenticated(this.userId, {required UserEntity user});
}

class AuthUnauthenticated extends AuthState {}

class onAuthenticated extends AuthState {}
