import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crumb/features/home/models/crumbs_model.dart';
import 'package:crumb/features/home/repository/HomeRepository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePageController extends ChangeNotifier {
  final HomeRepository _homeRepository = HomeRepository();
  bool isLoading = false;
  List<CrumbModel> crumbs = [];
  Map<String, bool> _rememberedCrumbs = {};
  Map<String, int> _rememberCount = {};

  Future<void> loadCrumbs(Position currentPosition) async {
    isLoading = true;
    notifyListeners();

    try {
      List<CrumbModel> allCrumbs = await _homeRepository.getCrumbs();

      crumbs = allCrumbs.where((crumb) {
        final double distanceInMeters = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          crumb.geopoint.latitude,
          crumb.geopoint.longitude,
        );
        return distanceInMeters <= 1000;
      }).toList();

      crumbs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Carregar o estado dos crumbs lembrados
      await _loadRememberedCrumbs();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      crumbs = [];
      notifyListeners();
      throw Exception("Erro ao carregar os crumbs: $e");
    }
  }

  Future<void> _loadRememberedCrumbs() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    for (CrumbModel crumb in crumbs) {
      bool isRemembered =
          await _homeRepository.isCrumbRememberedByUser(crumb.id, userId);
      _rememberedCrumbs[crumb.id] = isRemembered;

      int count = await _homeRepository.getRememberCount(crumb.id);
      _rememberCount[crumb.id] = count;
    }
  }

  bool isCrumbRemembered(String crumbId) {
    return _rememberedCrumbs[crumbId] ?? false;
  }

  int getRememberCount(String crumbId) {
    return _rememberCount[crumbId] ?? 0;
  }

  Future<void> toggleRememberCrumb(String crumbId, String crumbOwnerId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    if (_rememberedCrumbs[crumbId] == true) {
      await _homeRepository.removeRemember(crumbId, userId);
      _rememberedCrumbs[crumbId] = false;
      _rememberCount[crumbId] = _rememberCount[crumbId]! - 1;
    } else {
      await _homeRepository.addRemember(crumbId, userId, crumbOwnerId);
      _rememberedCrumbs[crumbId] = true;
      _rememberCount[crumbId] = _rememberCount[crumbId]! + 1;
    }
    notifyListeners();
  }

  // Função para buscar os detalhes do usuário (nickname e avatar)
  Future<Map<String, String>> getUserDetails(String userId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
}
