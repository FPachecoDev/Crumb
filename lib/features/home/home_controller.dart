import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crumb/features/home/models/crumbs_model.dart';
import 'package:crumb/features/home/repository/HomeRepository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class HomePageController extends ChangeNotifier {
  final HomeRepository _homeRepository = HomeRepository();
  bool isLoading = false;
  List<CrumbModel> crumbs = [];

  Future<void> loadCrumbs(Position currentPosition) async {
    isLoading = true;
    notifyListeners();

    try {
      // Busca os crumbs do repositório
      List<CrumbModel> allCrumbs = await _homeRepository.getCrumbs();

      // Filtra os crumbs para garantir que estejam dentro de 1km da localização atual
      crumbs = allCrumbs.where((crumb) {
        final double distanceInMeters = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          crumb.geopoint.latitude,
          crumb.geopoint.longitude,
        );
        return distanceInMeters <= 1000; // Filtra crumbs dentro de 1km
      }).toList();

      // Ordena os crumbs em ordem decrescente pelo timestamp
      crumbs.sort((a, b) =>
          b.timestamp.compareTo(a.timestamp)); // Ordenação decrescente

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      crumbs = [];
      notifyListeners();
      throw Exception("Erro ao carregar os crumbs: $e");
    }
  }

  Future<Map<String, String>> getUserDetails(String userId) async {
    // Implemente a lógica para obter os dados do usuário a partir do Firestore
    // Exemplo:
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists) {
      return {
        'nickname': doc.data()?['nickname'] ?? 'Usuário',
        'avatarUrl':
            doc.data()?['avatarUrl'] ?? '', // Adicione o avatarUrl aqui
      };
    }
    return {
      'nickname': 'Usuário',
      'avatarUrl': '', // Retorna uma string vazia se não existir
    };
  }
}
