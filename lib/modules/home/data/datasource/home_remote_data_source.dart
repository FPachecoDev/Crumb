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
        nearbyCrumbs.add(CrumbModel.fromFirestore(doc.id, data));
      }
    }

    return nearbyCrumbs;
  }
}
