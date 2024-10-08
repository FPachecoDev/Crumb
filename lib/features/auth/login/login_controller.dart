import 'package:crumb/features/auth/repository/auth_repository.dart';
import 'package:flutter/material.dart';

class LoginController with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  String? email;
  String? password;
  String? errorMessage;
  bool _isLoading = false; // Variável para controlar o estado de loading

  bool get isLoading => _isLoading; // Getter para isLoading

  // Verifica se o usuário já está logado
  Future<bool> checkLoginStatus() async {
    return await _authRepository.isLoggedIn();
  }

  // Lógica para efetuar o login
  Future<void> login(BuildContext context) async {
    errorMessage = null;
    _setLoading(true); // Inicia o estado de loading

    // Validação simples de email
    if (email == null || email!.isEmpty) {
      errorMessage = 'Por favor, insira um email.';
      _setLoading(false); // Para o loading se houver erro
      notifyListeners();
      return;
    }

    // Validação de email (pode ser melhorada com uma regex)
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email!)) {
      errorMessage = 'Email inválido.';
      _setLoading(false); // Para o loading se houver erro
      notifyListeners();
      return;
    }

    // Validação simples de senha
    if (password == null || password!.isEmpty) {
      errorMessage = 'Por favor, insira uma senha.';
      _setLoading(false); // Para o loading se houver erro
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
      _setLoading(false); // Para o loading após login
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      // Mensagem de erro baseada na falha
      errorMessage = 'Senha incorreta.';
      _setLoading(false); // Para o loading após erro
      notifyListeners();
    }
  }

  // Método para alterar o estado de loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Notifica o estado para a UI
  }
}
