import 'package:flutter/material.dart';
import 'package:crumb/features/onboarding/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late OnboardingController _controller;
  String? userId; // Variável para armazenar o userId do SharedPreferences

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController();
    _initializeOnboarding();
  }

  Future<void> _initializeOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId'); // Recupera o userId salvo

    if (userId != null) {
      await _controller.checkIfFirstTime(userId!);
      if (!_controller.isFirstTime) {
        Navigator.pushReplacementNamed(context, '/app');
      } else {
        setState(() {});
      }
    } else {
      // Se o userId não existir, navegue para a página de login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView(
              controller: _controller.pageController,
              onPageChanged: (int index) {
                setState(() {
                  _controller.currentPage = index;
                });
              },
              children: [
                OnboardingStep(
                  image: Icons.location_on,
                  title: 'Descubra suas memórias pelo caminho',
                  description:
                      'No Crumb, suas fotos são salvas exatamente onde você as tirou e só podem ser visualizadas quando você estiver pronto para revivê-las.',
                ),
                OnboardingStep(
                  image: Icons.place,
                  title: 'Reviva os momentos, no lugar certo',
                  description:
                      'Ao voltar ao local onde tirou a foto, ela se revela para você. Cada lembrança é um lugar especial.',
                ),
                OnboardingStep(
                  image: Icons.share,
                  title: 'Compartilhe suas memórias e colecione momentos!',
                  description:
                      'Poste suas fotos, receba comentários e likes. As fotos ficam meio apagadas até receberem um like, que as revela totalmente.',
                ),
                OnboardingStep(
                  image: Icons.explore,
                  title: 'Explore, curta e conecte-se',
                  description:
                      'Com o Crumb, suas memórias ganham vida onde elas nasceram. Aventure-se e veja o que seus amigos compartilharam por perto!',
                  isLastStep: true,
                  onLastStepComplete: () => _controller.completeOnboarding(
                      context, userId!), // Passa o userId
                ),
              ],
            ),
            // Setas de navegação posicionadas no bottom
            Positioned(
              left: 16,
              bottom: 30, // Posiciona o botão à esquerda no rodapé
              child: Visibility(
                visible: _controller.currentPage >
                    0, // Oculta a seta de voltar na primeira página
                child: IconButton(
                  icon: Icon(Icons.arrow_back, size: 30, color: Colors.grey),
                  onPressed: () {
                    _controller.pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 30, // Posiciona o botão à direita no rodapé
              child: Visibility(
                visible: _controller.currentPage <
                    _controller.totalPages -
                        1, // Oculta a seta de avançar na última página
                child: IconButton(
                  icon:
                      Icon(Icons.arrow_forward, size: 30, color: Colors.white),
                  onPressed: () {
                    _controller.pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingStep extends StatelessWidget {
  final IconData image;
  final String title;
  final String description;
  final bool isLastStep;
  final VoidCallback? onLastStepComplete;

  const OnboardingStep({
    required this.image,
    required this.title,
    required this.description,
    this.isLastStep = false,
    this.onLastStepComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(image, size: 100, color: Colors.blue),
          SizedBox(height: 40),
          Text(
            title,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          if (isLastStep)
            ElevatedButton(
              onPressed: onLastStepComplete,
              child: Text(
                'Começar!',
                style: TextStyle(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}
