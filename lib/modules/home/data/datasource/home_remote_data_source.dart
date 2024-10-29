import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/crumb_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CrumbModel>> getNearbyCrumbs(Position userPosition);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore firestore;

  HomeRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<CrumbModel>> getNearbyCrumbs(Position userPosition) async {
    final snapshot = await firestore.collection('crumbs').get();
    final nearbyCrumbs = <CrumbModel>[];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final GeoPoint geoPoint = data['geopoint'];
      final double distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        geoPoint.latitude,
        geoPoint.longitude,
      );

      // Apenas adiciona os crumbs próximos, dentro do raio de 1 km
      if (distance <= 1000) {
        // Busca o ID do usuário que publicou este crumb
        final String userId = data['userId'];
        final userSnapshot =
            await firestore.collection('users').doc(userId).get();

        // Verifica se os dados do usuário existem e obtém o nome
        final String userName = userSnapshot.exists
            ? (userSnapshot.data()?['name'] ?? 'Desconhecido')
            : 'Desconhecido';

        // Cria o CrumbModel com o nome do usuário
        final crumb = CrumbModel.fromFirestore(doc.id, {
          ...data,
          'userName':
              userName, // Adiciona o nome do usuário ao mapa de dados do crumb
        });
        nearbyCrumbs.add(crumb);
      }
    }

    return nearbyCrumbs;
  }
}
