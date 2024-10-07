import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crumb/features/global/model/global_crumb_model.dart';

class GlobalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<GlobalCrumbModel>> getCrumbsFromFirebase() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('crumbs').get();
      return snapshot.docs.map((doc) {
        return GlobalCrumbModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw Exception("Erro ao buscar os crumbs: $e");
    }
  }
}
