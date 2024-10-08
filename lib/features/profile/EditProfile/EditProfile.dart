import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import para escolher a imagem
import 'package:firebase_storage/firebase_storage.dart'; // Para upload no Firebase
import 'EditProfile_controller.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final EditProfileController _controller = EditProfileController();

  // Controladores para os campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _dobController =
      TextEditingController(); // Data de nascimento
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _image; // Armazena a imagem do avatar temporário
  String? _uploadedImageUrl; // URL da imagem do avatar no Firebase
  File? _backgroundImage; // Armazena a imagem de fundo temporária
  String? _uploadedBackgroundUrl; // URL da imagem de fundo no Firebase

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Carregar dados do usuário na inicialização
  }

  Future<void> _loadUserData() async {
    try {
      // Obter o usuário logado
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String userId = currentUser.uid;

        // Buscar os dados do usuário no Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          // Inicializar os controladores com os dados do Firestore
          _nameController.text = userData?['name'] ?? '';
          _surnameController.text = userData?['surname'] ?? '';
          _nicknameController.text = userData?['nickname'] ?? '';
          _dobController.text = userData?['dob'] ?? '';
          _emailController.text = userData?['email'] ?? '';
          _uploadedImageUrl = userData?['avatarUrl'] ?? '';
          _uploadedBackgroundUrl =
              userData?['backgroundUrl'] ?? ''; // Adicionando a URL do fundo

          // Atualizar o estado para refletir as mudanças
          setState(() {});
        }
      }
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
    }
  }

  // FUNCAO DO BACKGROUND/ CAPA -----------------------------------------------------------------

  // Função para pegar a imagem da galeria para o fundo
  Future<void> _pickImageBackground() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _backgroundImage =
            File(pickedFile.path); // Armazena a imagem temporária
      });
    }
  }

  // Função para salvar a imagem de fundo no Firebase Storage
  Future<String?> _uploadImageBackground(String userId) async {
    if (_backgroundImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('background')
          .child('$userId.jpg');
      await storageRef.putFile(_backgroundImage!);
      return await storageRef.getDownloadURL(); // Retorna a URL da imagem
    } catch (e) {
      print("Erro ao fazer upload da imagem: $e");
      return null;
    }
  }

  // -------------------------------------------------------------------------------------

  // FUNCAO DO AVATAR -----------------------------------------------------------------

  // Função para pegar a imagem da galeria
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Armazena a imagem temporária
      });
    }
  }

  // Função para salvar a imagem no Firebase Storage
  Future<String?> _uploadImage(String userId) async {
    if (_image == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePictures')
          .child('$userId.jpg');
      await storageRef.putFile(_image!);
      return await storageRef.getDownloadURL(); // Retorna a URL da imagem
    } catch (e) {
      print("Erro ao fazer upload da imagem: $e");
      return null;
    }
  }

  // -------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _backgroundImage != null
                        ? FileImage(_backgroundImage!)
                        : (_uploadedBackgroundUrl != null &&
                                _uploadedBackgroundUrl!.isNotEmpty)
                            ? NetworkImage(_uploadedBackgroundUrl!)
                            : NetworkImage(
                                    'https://img.freepik.com/fotos-gratis/plano-de-fundo-texturizado-de-concreto-grunge-preto_53876-124541.jpg')
                                as ImageProvider, // Imagem padrão
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                child: GestureDetector(
                  onTap: _pickImage, // Ação de abrir a galeria para o avatar
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : (_uploadedImageUrl != null &&
                                _uploadedImageUrl!.isNotEmpty)
                            ? NetworkImage(_uploadedImageUrl!)
                            : AssetImage('assets/default_avatar.png')
                                as ImageProvider, // Imagem padrão
                    child: const Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 18,
                        child: Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap:
                      _pickImageBackground, // Ação de abrir a galeria para o fundo
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.image, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildTextField("Nome", _nameController),
                SizedBox(
                  height: 10,
                ),
                _buildTextField("Sobrenome", _surnameController),
                SizedBox(
                  height: 10,
                ),
                _buildTextField("Nickname", _nicknameController),
                SizedBox(
                  height: 10,
                ),
                _buildTextField("Data de Nascimento", _dobController),
                SizedBox(
                  height: 10,
                ),
                _buildTextField("Email", _emailController),
                SizedBox(
                  height: 10,
                ),
                _buildTextField("Senha", _passwordController,
                    obscureText: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Código para atualizar os dados do usuário
                    User? currentUser = FirebaseAuth.instance.currentUser;

                    if (currentUser != null) {
                      String userId = currentUser.uid;

                      // Fazer upload das imagens e obter as URLs
                      String? avatarUrl = await _uploadImage(userId);
                      String? backgroundUrl =
                          await _uploadImageBackground(userId);

                      // Atualizar os dados do usuário no Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .update({
                        'name': _nameController.text,
                        'surname': _surnameController.text,
                        'nickname': _nicknameController.text,
                        'dob': _dobController.text,
                        'email': _emailController.text,
                        'avatarUrl': avatarUrl ?? _uploadedImageUrl,
                        'backgroundUrl':
                            backgroundUrl ?? _uploadedBackgroundUrl,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Perfil atualizado com sucesso!')),
                      );
                    }
                  },
                  child: const Text('Salvar Alterações'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.black),
                    foregroundColor:
                        MaterialStatePropertyAll<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    // Função para exibir diálogo de logout
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed(
                    '/login'); // Navegar para a página de login
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}
