// lib/features/auth/register/register_controller.dart
import 'package:crumb/features/auth/models/users_model.dart';
import 'package:crumb/features/auth/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterController extends ChangeNotifier {
  String name = '';
  String surname = '';
  String nickname = '';
  String email = '';
  String password = '';
  String dateOfBirth = '';
  bool acceptedTerms = false;
  bool isLoading = false;
  String? errorMessage;

  final UserRepository _userRepository;

  RegisterController(this._userRepository);

  // Funções para atualizar os campos do formulário
  void updateName(String value) {
    name = value;
    notifyListeners();
  }

  void updateSurname(String value) {
    surname = value;
    notifyListeners();
  }

  void updateNickname(String value) {
    nickname = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }

  void updateDateOfBirth(String value) {
    dateOfBirth = value;
    notifyListeners();
  }

  void toggleAcceptedTerms(bool? value) {
    acceptedTerms = value ?? false;
    notifyListeners();
  }

  bool validateFields() {
    if (name.isEmpty ||
        surname.isEmpty ||
        nickname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        dateOfBirth.isEmpty) {
      errorMessage = 'Todos os campos devem ser preenchidos';
      notifyListeners();
      return false;
    }
    if (!acceptedTerms) {
      errorMessage = 'Você deve aceitar os termos';
      notifyListeners();
      return false;
    }
    errorMessage = null;
    return true;
  }

  Future<void> onRegister(BuildContext context) async {
    if (!validateFields()) return;

    isLoading = true;
    notifyListeners();

    try {
      // Chamada do repositório para criar um usuário
      final user = await _userRepository.createUser(
        name: name,
        surname: surname,
        nickname: nickname,
        email: email,
        password: password,
        dateOfBirth: dateOfBirth,
      );

      if (user != null) {
        // Sucesso no registro
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        isLoading = false;
        notifyListeners();

        Navigator.pushReplacementNamed(context, '/app');
      } else {
        throw Exception('Erro ao criar usuário');
      }
    } catch (error) {
      isLoading = false;
      errorMessage = 'Ocorreu um erro ao registrar o usuário';
      notifyListeners();
    }
  }
}
