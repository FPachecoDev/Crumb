// lib/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função de login usando Firebase Authentication
  Future<bool> login(String email, String password) async {
    try {
      // Tenta fazer login com o email e a senha fornecidos
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Se o login for bem-sucedido, salve o userId e o email
      if (userCredential.user != null) {
        await saveUserCredentials(email, userCredential.user!.uid);
        return true; // Retorna true se o login for bem-sucedido
      }
      return false; // Retorna false se o login falhar
    } on FirebaseAuthException catch (e) {
      // Trate as exceções de autenticação
      if (e.code == 'user-not-found') {
        print('Nenhum usuário encontrado para esse email.');
      } else if (e.code == 'wrong-password') {
        print('Senha incorreta.');
      }
      return false; // Retorna false se o login falhar
    } catch (e) {
      print('Erro ao fazer login: $e');
      return false;
    }
  }

  // Salva as credenciais do usuário (email e userId) usando SharedPreferences
  Future<void> saveUserCredentials(String email, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'email', email); // Armazena o email no SharedPreferences
    await prefs.setString(
        'userId', userId); // Armazena o userId no SharedPreferences
    await prefs.setBool(
        'isLoggedIn', true); // Define o estado de logado como verdadeiro
  }

  // Recupera o email do usuário armazenado no SharedPreferences
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email'); // Recupera o email do SharedPreferences
  }

  // Recupera o userId do usuário armazenado no SharedPreferences
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // Recupera o userId do SharedPreferences
  }

  // Verifica se o usuário está logado com base no estado salvo no SharedPreferences
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ??
        false; // Retorna true se estiver logado
  }

  // Função de logout que remove as credenciais e faz sign out do Firebase
  Future<void> logout() async {
    await _auth.signOut(); // Faz logout do Firebase
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email'); // Remove o email armazenado
    await prefs.remove('userId'); // Remove o userId armazenado
    await prefs.setBool(
        'isLoggedIn', false); // Define o estado de logado como falso
  }
}
