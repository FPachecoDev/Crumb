import 'package:crumb/features/profile/repository/EditProfile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileController {
  final EditProfileRepository _repository = EditProfileRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função para obter o ID do usuário logado
  String? getCurrentUserId() {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  // Função para atualizar os dados do perfil
  Future<void> updateProfile(
    String name,
    String surname,
    String nickname,
    String dob,
    String email,
    String password,
  ) async {
    try {
      String? userId = getCurrentUserId();
      if (userId != null) {
        // Chama o repositório para atualizar os dados
        await _repository.updateUserProfile(
          userId,
          name,
          surname,
          nickname,
          dob,
          email,
          password,
        );
        print('Perfil atualizado com sucesso');
      } else {
        print('Usuário não logado');
      }
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
    }
  }

  // Função de logout que limpa os dados do SharedPreferences e redireciona para a página de login
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Remove todos os dados armazenados

    // Navega para a página de login (supondo que seja LoginPage)
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
