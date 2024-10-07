import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para atualizar o perfil do usuário no Firebase
  Future<void> updateUserProfile(
    String userId,
    String name,
    String surname,
    String nickname,
    String dob,
    String email,
    String password,
  ) async {
    try {
      // Referência ao documento do usuário na coleção "users"
      DocumentReference userRef = _firestore.collection('users').doc(userId);

      // Atualiza os dados do usuário no Firebase
      await userRef.update({
        'name': name,
        'surname': surname,
        'nickname': nickname,
        'dob': dob,
        'email': email,
        'password':
            password, // Você deve considerar um método mais seguro para armazenar senhas!
      });

      print('Dados do usuário atualizados com sucesso no Firebase');
    } catch (e) {
      print('Erro ao atualizar o perfil no Firebase: $e');
      throw Exception('Não foi possível atualizar os dados do usuário');
    }
  }
}
