// lib/pages/register_page.dart
import 'package:crumb/features/auth/register/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final registerController = Provider.of<RegisterController>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://images.pexels.com/photos/3264736/pexels-photo-3264736.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 60),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ), // Ícone de voltar
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 100),

                  _buildTextField(
                    label: 'Nome',
                    onChanged: registerController.updateName,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Sobrenome',
                    onChanged: registerController.updateSurname,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Apelido',
                    onChanged: registerController.updateNickname,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Data de Nascimento (DD/MM/AAAA)',
                    onChanged: registerController.updateDateOfBirth,
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'email@email.com',
                    onChanged: registerController.updateEmail,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Senha',
                    onChanged: registerController.updatePassword,
                    obscureText: true,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: registerController.acceptedTerms,
                        onChanged: registerController.toggleAcceptedTerms,
                      ),
                      const Text(
                        'Aceite os termos',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  if (registerController.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        registerController.errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Botão "Cadastrar"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: registerController.isLoading
                          ? null
                          : () => registerController
                              .onRegister(context), // Passa o contexto aqui
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: registerController.isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Cadastrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função para criar campos de texto
  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        hintText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
