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

  // Função para buscar os detalhes do usuário (nickname e avatar)
  Future<Map<String, String>> getUserDetails(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return {
          'nickname': data['nickname'] ?? "Nickname não encontrado",
          'avatarUrl': data['avatarUrl'] ?? ""
        };
      } else {
        throw Exception("Usuário não encontrado");
      }
    } catch (e) {
      throw Exception("Erro ao buscar detalhes do usuário: $e");
    }
  }

  // Função para verificar se um crumb foi lembrado (curtido) por um usuário
  Future<bool> isCrumbRememberedByUser(String crumbId, String userId) async {
    try {
      final doc = await _firestore
          .collection('crumbs')
          .doc(crumbId)
          .collection('remembers')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      throw Exception("Erro ao verificar se o crumb foi lembrado: $e");
    }
  }

  // Função para buscar a contagem de 'remembers' (curtidas) de um crumb
  Future<int> getRememberCount(String crumbId) async {
    try {
      final snapshot = await _firestore
          .collection('crumbs')
          .doc(crumbId)
          .collection('remembers')
          .get();
      return snapshot.size;
    } catch (e) {
      throw Exception("Erro ao buscar contagem de remembers: $e");
    }
  }

  // Função para adicionar um 'remember' (curtir) a um crumb
  Future<void> addRemember(
      String crumbId, String userId, String crumbOwnerId) async {
    try {
      await _firestore
          .collection('crumbs')
          .doc(crumbId)
          .collection('remembers')
          .doc(userId)
          .set({
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Erro ao adicionar remember: $e");
    }
  }

  // Função para remover um 'remember' (descurtir) de um crumb
  Future<void> removeRemember(String crumbId, String userId) async {
    try {
      await _firestore
          .collection('crumbs')
          .doc(crumbId)
          .collection('remembers')
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception("Erro ao remover remember: $e");
    }
  }
}
