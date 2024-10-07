// lib/features/auth/login/login_controller.dart
import 'package:crumb/features/auth/repository/auth_repository.dart';
import 'package:flutter/material.dart';

class LoginController with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  String? email;
  String? password;
  String? errorMessage;

  // Verifica se o usuário já está logado
  Future<bool> checkLoginStatus() async {
    return await _authRepository.isLoggedIn();
  }

  // Lógica para efetuar o login
  Future<void> login(BuildContext context) async {
    errorMessage = null;

    // Validação simples de email
    if (email == null || email!.isEmpty) {
      errorMessage = 'Por favor, insira um email.';
      notifyListeners();
      return;
    }

    // Validação de email (pode ser melhorada com uma regex)
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email!)) {
      errorMessage = 'Email inválido.';
      notifyListeners();
      return;
    }

    // Validação simples de senha
    if (password == null || password!.isEmpty) {
      errorMessage = 'Por favor, insira uma senha.';
      notifyListeners();
      return;
    }

    // Tenta efetuar login
    bool success = await _authRepository.login(email!, password!);
    if (success) {
      // Recupera o userId após um login bem-sucedido
      String? userId = await _authRepository.getUserId();
      // Salva o estado de login se o login for bem-sucedido
      await _authRepository.saveUserCredentials(email!, userId!);
      // Navega para a página home
      Navigator.pushReplacementNamed(
          context, '/app'); // Ajuste o nome da rota conforme sua necessidade
    } else {
      // Mensagem de erro baseada na falha
      errorMessage = 'Senha incorreta.';
      notifyListeners();
    }
  }
}
