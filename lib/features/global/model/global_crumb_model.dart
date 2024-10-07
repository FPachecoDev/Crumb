import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalCrumbModel {
  final String id;
  final String caption;
  final String city;
  final String country;
  final String neighborhood;
  final String postalCode;
  final String street;
  final GeoPoint geopoint;
  final String mediaUrl;
  final DateTime timestamp;
  final String userId;

  GlobalCrumbModel({
    required this.id,
    required this.caption,
    required this.city,
    required this.country,
    required this.neighborhood,
    required this.postalCode,
    required this.street,
    required this.mediaUrl,
    required this.timestamp,
    required this.userId,
    required this.geopoint,
  });

  factory GlobalCrumbModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return GlobalCrumbModel(
      id: doc.id,
      caption: data['caption'] ?? '', // Tratar valores nulos com strings vazias
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      neighborhood: data['neighborhood'] ?? '',
      postalCode: data['postalCode'] ?? '',
      street: data['street'] ?? '',
      geopoint: doc['geopoint'] as GeoPoint,
      mediaUrl: data['mediaUrl'] ?? '',
      timestamp: (data['timestamp'] != null)
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(), // Tratar timestamp nulo
      userId: data['userId'] ?? '',
    );
  }
}
