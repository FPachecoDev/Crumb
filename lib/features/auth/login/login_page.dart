// lib/pages/login_page.dart
import 'package:crumb/app.dart';
import 'package:crumb/features/auth/register/register_page.dart';
import 'package:crumb/features/auth/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isImageLoaded = false; // Flag para controlar o carregamento da imagem

  @override
  Widget build(BuildContext context) {
    final loginController =
        Provider.of<LoginController>(context); // Obtém o controlador de login

    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo com indicador de carregamento
          Positioned.fill(
            child: Image.network(
              'https://images.pexels.com/photos/3264736/pexels-photo-3264736.jpeg', // URL da imagem
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) {
                  // Quando a imagem foi totalmente carregada
                  return child;
                } else {
                  return Container(
                    color: Colors.black, // Fundo preto enquanto carrega
                    child: Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                (progress.expectedTotalBytes ?? 1)
                            : null,
                        color: Colors.white, // Indicador de progresso em branco
                      ),
                    ),
                  );
                }
              },
              // Quando a imagem for carregada, muda o estado para exibir o conteúdo da página
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _isImageLoaded = true;
                    });
                  });
                }
                return child;
              },
            ),
          ),
          // Exibe o conteúdo apenas após a imagem de fundo ser carregada
          if (_isImageLoaded)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título "Crumb"
                      const Text(
                        'Crumb.',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Criando novas historias.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 300),
                      // Campo de email
                      TextField(
                        onChanged: (value) {
                          loginController.email =
                              value; // Atualiza o email no controlador
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          hintText: 'email@email.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Campo de senha
                      TextField(
                        onChanged: (value) {
                          loginController.password =
                              value; // Atualiza a senha no controlador
                        },
                        obscureText: true, // Campo de password
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          hintText: '********',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Exibe mensagem de erro se houver
                      if (loginController.errorMessage != null)
                        Text(
                          loginController.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 16),
                      // Botão "Entrar"
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Ação ao clicar no botão de login
                            loginController.login(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Fundo preto
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(
                              color: Colors.white, // Texto branco
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Texto "Cadastre-se usando email"
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        ),
                        child: const Text(
                          'Cadastre-se usando email',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
