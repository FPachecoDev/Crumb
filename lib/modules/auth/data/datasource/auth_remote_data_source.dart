// lib/features/auth/data/datasource/auth_remote_data_source.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para login
  Future<UserModel> login(String email, String password) async {
    UserCredential userCredential =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    DocumentSnapshot snapshot = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (snapshot.data() == null) {
      throw Exception('Dados do usuário não encontrados.');
    }
    await _saveUserId(userCredential.user!.uid);
    return UserModel.fromMap(
        snapshot.data() as Map<String, dynamic>, userCredential.user!.uid);
  }

  Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  // Método para registrar um usuário
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String nickname,
    required bool acceptedTerms,
    required DateTime dateOfBirth, // Adicionado parâmetro dateOfBirth
  }) async {
    // Fazendo a autenticação com o Firebase Auth
    UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    UserModel user = UserModel(
      id: userCredential.user!.uid,
      email: email,
      name: name,
      surname: surname,
      nickname: nickname,
      avatarUrl: '',
      backgroundUrl: '',
      dateOfBirth: dateOfBirth,
      acceptedTerms: acceptedTerms,
      password: password,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.id).set(user.toMap());

    await _saveUserId(user.id);
    return user;
  }

  // Salva o id no sharedprefence para verificar se o usuario esta logado
  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }
}
