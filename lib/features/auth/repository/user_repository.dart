// lib/repositories/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crumb/features/auth/models/users_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> createUser({
    required String name,
    required String surname,
    required String nickname,
    required String email,
    required String password,
    required String dateOfBirth,
  }) async {
    try {
      // Criação do usuário no Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Criação do modelo UserModel
      UserModel user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        surname: surname,
        nickname: nickname,
        email: email,
        password: password, // Você pode querer não armazenar a senha
        dateOfBirth: dateOfBirth,
        acceptedTerms: true,
        createdAt:
            DateTime.now(), // Adicione um parâmetro para aceitar os termos
      );

      // Salva o usuário no Firestore
      await _firestore.collection('users').doc(user.id).set(user.toJson());

      // Salva o userId no SharedPreferences
      await _saveUserId(user.id);

      return user;
    } on FirebaseAuthException catch (e) {
      // Trate as exceções de autenticação
      if (e.code == 'weak-password') {
        print('A senha fornecida é muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        print('Um usuário já existe para esse e-mail.');
      }
      return null;
    } catch (e) {
      print('Erro ao criar o usuário: $e');
      return null;
    }
  }

  // Método para salvar o userId no SharedPreferences
  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'userId', userId); // Armazena o userId no SharedPreferences
  }
}
