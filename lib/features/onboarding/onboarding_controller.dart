import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController {
  final PageController pageController = PageController();
  bool isFirstTime = true; // Supondo que você tenha uma lógica para isso
  int _currentPage = 0; // Inicializando a página atual

  // Getter para a página atual
  int get currentPage => _currentPage;

  // Setter para atualizar a página atual
  set currentPage(int value) {
    _currentPage = value;
  }

  // Getter para o total de páginas (defina de acordo com o número de etapas)
  int get totalPages =>
      4; // Se você tiver 4 páginas, ajuste conforme necessário

  // Verifica se o usuário já passou pelo onboarding com base no userId salvo no SharedPreferences
  Future<void> checkIfFirstTime(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('onboarding_$userId') ?? true;
  }

  // Função para salvar que o usuário completou o onboarding
  Future<void> completeOnboarding(BuildContext context, String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_$userId', false);
    Navigator.pushReplacementNamed(
        context, '/app'); // Navega para a home após completar o onboarding
  }

  // Dispose para o PageController
  void dispose() {
    pageController.dispose();
  }
}
