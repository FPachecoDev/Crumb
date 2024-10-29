import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crumb/modules/home/domain/entities/crumb_entity.dart';

class CrumbModel extends CrumbEntity {
  CrumbModel({
    required String id,
    required String street,
    required String caption,
    required double latitude,
    required double longitude,
    required String userName,
  }) : super(
            id: id,
            street: street,
            caption: caption,
            latitude: latitude,
            longitude: longitude,
            userName: userName);

  // Método para converter dados do Firestore para CrumbModel
  factory CrumbModel.fromFirestore(String id, Map<String, dynamic> data) {
    final GeoPoint geoPoint = data['geopoint'];
    return CrumbModel(
        id: id,
        street: data['street'] ?? '',
        caption: data['caption'] ?? '',
        latitude: geoPoint.latitude,
        longitude: geoPoint.longitude,
        userName: data['userName']);
  }
}
