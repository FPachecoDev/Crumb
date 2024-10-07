import 'package:cloud_firestore/cloud_firestore.dart'; // Importa o Firestore
import 'package:crumb/features/profile/models/profile_users_model.dart';
import 'package:crumb/features/profile/repository/profile_repository.dart';
import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();
  UserProfileModel? user;
  bool isLoading = true; // Controle de loading
  bool _isDisposed = false; // Controle de estado do widget

  // Função para buscar o perfil do usuário pelo ID
  Future<void> loadUserProfile(String userId) async {
    isLoading = true; // Inicia o loading
    notifyListeners();

    user = await _profileRepository.fetchUserById(userId);

    // Chama o método para carregar os crumbs do usuário
    await loadUserCrumbs(userId);

    isLoading = false; // Para o loading quando os dados forem carregados

    // Verifica se o estado do widget não foi desmontado antes de notificar
    if (!_isDisposed) {
      notifyListeners(); // Notifica a UI que os dados mudaram
    }
  }

  // Método para carregar os crumbs do usuário
  Future<void> loadUserCrumbs(String userId) async {
    // Obtém a instância do Firestore
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Busca os crumbs do usuário pelo ID
    QuerySnapshot crumbsSnapshot = await _firestore
        .collection('crumbs')
        .where('userId', isEqualTo: userId) // Filtra os crumbs do usuário
        .get();

    // Adiciona os URLs das imagens ao modelo de usuário
    user?.photos =
        crumbsSnapshot.docs.map((doc) => doc['mediaUrl'] as String).toList();
  }

  // Método que deve ser chamado ao descartar o controller
  @override
  void dispose() {
    _isDisposed = true; // Marca como desmontado
    super.dispose();
  }
}
