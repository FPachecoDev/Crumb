import 'package:cloud_firestore/cloud_firestore.dart';

class CrumbModel {
  final String id;
  final String mediaUrl;
  final String userId;
  final String caption;
  final String city;
  final String country;
  final String neighborhood;
  final String postalCode;
  final String street;
  final GeoPoint geopoint;
  final DateTime timestamp;

  CrumbModel({
    required this.id,
    required this.mediaUrl,
    required this.userId,
    required this.caption,
    required this.city,
    required this.country,
    required this.neighborhood,
    required this.postalCode,
    required this.street,
    required this.geopoint,
    required this.timestamp, // Campo timestamp no construtor
  });

  // Factory method para criar um CrumbModel a partir de um Map (como os dados do Firestore)
  factory CrumbModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CrumbModel(
      id: documentId,
      mediaUrl: data['mediaUrl'] ?? '',
      userId: data['userId'] ?? '',
      caption: data['caption'] ?? '',
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      neighborhood: data['neighborhood'] ?? '',
      postalCode: data['postalCode'] ?? '',
      street: data['street'] ?? '',
      geopoint: data['geopoint'] as GeoPoint,
      timestamp: (data['timestamp'] as Timestamp).toDate(), // Trata o timestamp
    );
  }
}
