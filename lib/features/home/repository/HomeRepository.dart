import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crumb/features/home/models/crumbs_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para buscar todos os crumbs
  Future<List<CrumbModel>> getCrumbs() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('crumbs').get();
      return snapshot.docs.map((doc) {
        return CrumbModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception("Erro ao buscar crumbs: $e");
    }
  }

  // Função para buscar o nickname do usuário pelo userId
  Future<String> getUserNickname(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data['nickname'] ?? "Nickname não encontrado";
      } else {
        throw Exception("Usuário não encontrado");
      }
    } catch (e) {
      throw Exception("Erro ao buscar o nickname do usuário: $e");
    }
  }
}
