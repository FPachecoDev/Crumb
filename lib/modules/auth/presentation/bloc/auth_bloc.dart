// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:crumb/modules/auth/domain/entities/user_register_entity.dart';
import 'package:crumb/modules/auth/domain/usecases/logout_usecase.dart';
import 'package:crumb/modules/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/failures/auth_failure.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc(
      {required this.loginUseCase,
      required this.registerUseCase,
      required this.logoutUseCase})
      : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUseCase(event.email, event.password);
        emit(AuthAuthenticated(
          event.email,
          user: user,
        ));

        // Chama o callback para navegação após autenticação
        if (onAuthenticated != null) {
          onAuthenticated();
        }
      } catch (e) {
        if (e is AuthFailure) {
          emit(AuthError(message: e.message));
        } else {
          emit(AuthError(message: 'Erro desconhecido: ${e.toString()}'));
        }
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await registerUseCase(
            event.email,
            event.password,
            event.name,
            event.nickname,
            event.surname,
            event.acceptedTerms,
            event.dateOfBirth);
        emit(RegisterUserEntity(
          email: event.email,
          acceptedTerms: event.acceptedTerms,
          name: event.name,
          dateOfBirth: event.dateOfBirth,
          password: event.password,
          surname: event.surname,
          nickname: event.nickname,
        ) as AuthState);
      } catch (e) {
        if (e is AuthFailure) {
          emit(AuthError(message: e.message));
        } else {
          emit(AuthError(message: 'Erro desconhecido: ${e.toString()}'));
        }
      }
    });

    on<LogoutEvent>((event, emit) async {
      try {
        await logoutUseCase();
      } catch (e) {
        if (e is AuthFailure) {
          emit(AuthError(message: e.message));
        } else {
          emit(AuthError(message: 'Erro desconhecido: ${e.toString()}'));
        }
      }
    });
  }
}
