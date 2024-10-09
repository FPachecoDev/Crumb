import 'dart:async';
import 'package:crumb/app.dart';
import 'package:crumb/features/auth/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with TickerProviderStateMixin {
  String firstText = "Crie novas histórias";
  String secondText = "Viva novas histórias";
  String thirdText = "Crumb.";
  String displayedText = "";
  int textIndex = 0;
  bool isSecondPhase = false;
  bool showThirdText = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _startFirstPhase();
  }

  void _startFirstPhase() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (textIndex < firstText.length) {
        setState(() {
          displayedText += firstText[textIndex];
          textIndex++;
        });
      } else {
        timer.cancel();
        _startSecondPhase();
      }
    });
  }

  void _startSecondPhase() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        displayedText = "";
        textIndex = 0;
        isSecondPhase = true;
      });
      Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (textIndex < secondText.length) {
          setState(() {
            displayedText += secondText[textIndex];
            textIndex++;
          });
        } else {
          timer.cancel();
          _startThirdPhase();
        }
      });
    });
  }

  void _startThirdPhase() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        displayedText = ""; // Oculta o texto anterior
        showThirdText = true; // Inicia a exibição do terceiro texto
      });
      _fadeController.forward();
      _endSplashScreen();
    });
  }

  void _endSplashScreen() {
    Future.delayed(Duration(seconds: 3), () async {
      // Verifica se o usuário já está logado
      final prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => isLoggedIn ? App() : LoginPage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!showThirdText) // Exibe o texto anterior até a terceira fase começar
                Text(
                  displayedText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: 20),
              if (showThirdText)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    thirdText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
