import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crumb/modules/home/domain/entities/crumb_entity.dart';

class CrumbModel extends CrumbEntity {
  CrumbModel({
    required String id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
  }) : super(
          id: id,
          title: title,
          description: description,
          latitude: latitude,
          longitude: longitude,
        );

  // Método para converter dados do Firestore para CrumbModel
  factory CrumbModel.fromFirestore(String id, Map<String, dynamic> data) {
    final GeoPoint geoPoint = data['geopoint'];
    return CrumbModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
    );
  }
}
