// lib/features/global/controller/global_controller.dart
import 'package:flutter/material.dart';
import 'package:crumb/features/global/repository/global_repository.dart';
import 'package:crumb/features/global/model/global_crumb_model.dart';

class GlobalController extends ChangeNotifier {
  final GlobalRepository _repository = GlobalRepository();
  List<GlobalCrumbModel> _crumbs = [];
  bool _isLoading = true;

  List<GlobalCrumbModel> get crumbs => _crumbs;
  bool get isLoading => _isLoading;

  Future<void> fetchCrumbs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _crumbs = await _repository.getCrumbsFromFirebase();
    } catch (e) {
      print("Erro ao buscar crumbs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
