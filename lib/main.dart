import 'package:crumb/features/auth/login/login_controller.dart';
import 'package:crumb/features/auth/login/login_page.dart';
import 'package:crumb/features/auth/register/register_controller.dart';
import 'package:crumb/features/auth/register/register_page.dart';
import 'package:crumb/features/auth/repository/user_repository.dart';
import 'package:crumb/features/create/create_controller.dart';
import 'package:crumb/features/global/global_controller.dart';
import 'package:crumb/features/home/home_controller.dart';
import 'package:crumb/features/home/home_page.dart';
import 'package:crumb/features/onboarding/onboarding_controller.dart';
import 'package:crumb/features/onboarding/onboarding_page.dart';
import 'package:crumb/features/profile/profile_controller.dart';
import 'package:crumb/features/splashscreen/splashscreen_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import para usar SharedPreferences
import 'firebase_options.dart';

import 'app.dart'; // Importação do arquivo do aplicativo principal

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Garante que o Firebase seja inicializado corretamente
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => RegisterController(
                UserRepository())), // Injeção do UserRepository no RegisterController
        ChangeNotifierProvider(
            create: (_) =>
                LoginController()), // Injeção do AuthRepository no RegisterController

        ChangeNotifierProvider(
            create: (_) =>
                CreatePageController()), // Injeção do AuthRepository no RegisterController

        ChangeNotifierProvider(
            create: (_) =>
                HomePageController()), // Injeção do HomeController no RegisterController

        ChangeNotifierProvider(
            create: (_) =>
                ProfileController()), // Injeção do HomeController no RegisterControlle

        ChangeNotifierProvider(create: (_) => GlobalController()),

        ChangeNotifierProvider(
            create: (_) =>
                ProfileController()), // Injeção do HomeController no RegisterControlle
      ],
      child: MyApp(), // Passa o estado de login para o MyApp
    ),
  );
}

class MyApp extends StatelessWidget {
  // Construtor que aceita o estado de login
  MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crumb App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Se o usuário estiver logado, redireciona para a página principal (App), caso contrário, para o login
      home: SplashScreenPage(),
      routes: {
        '/login': (context) => LoginPage(), // Rota para LoginPage
        '/register': (context) => RegisterPage(), // Rota para RegisterPage
        '/app': (context) => App(), // Rota para home do app
        '/onboarding': (context) =>
            OnboardingPage(), // Rota para oboarding do app
      },
    );
  }
}
