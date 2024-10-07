import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crumb/features/profile/models/profile_users_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para buscar todos os usuários do Firestore
  Future<UserProfileModel?> fetchUserById(String userId) async {
    try {
      DocumentSnapshot document =
          await _firestore.collection('users').doc(userId).get();

      if (document.exists) {
        return UserProfileModel.fromMap(
            document.data() as Map<String, dynamic>, document.id);
      }
      return null;
    } catch (e) {
      print("Erro ao buscar o usuário: $e");
      return null;
    }
  }
}
