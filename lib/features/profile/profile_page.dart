import 'package:crumb/features/profile/EditProfile/EditProfile.dart';
import 'package:crumb/features/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para gerenciar o estado com ChangeNotifier

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this); // Controlador do TabBar com duas abas

    // Chamando a função para carregar o perfil do usuário
    _loadUserProfile();
  }

  // Função separada para carregar o ID do usuário e carregar o perfil
  Future<void> _loadUserProfile() async {
    _profileController = Provider.of<ProfileController>(context, listen: false);

    String userId = await _getUserId(); // Recupera o ID do SharedPreferences
    _profileController.loadUserProfile(
        userId); // Carrega o perfil do usuário com o ID recuperado
  }

  // Função para obter o ID do usuário do SharedPreferences
  Future<String> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ??
        ''; // Retorna o ID salvo ou uma string vazia se não encontrado
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Capa de fundo
                  Consumer<ProfileController>(
                    // Modificado para usar Consumer
                    builder: (context, controller, child) {
                      String backgroundUrl = controller.user?.backgroundUrl ??
                          'https://img.freepik.com/fotos-gratis/plano-de-fundo-texturizado-de-concreto-grunge-preto_53876-124541.jpg'; // URL padrão se não houver
                      return Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: backgroundUrl == ''
                                ? NetworkImage(
                                    'https://img.freepik.com/fotos-gratis/plano-de-fundo-texturizado-de-concreto-grunge-preto_53876-124541.jpg')
                                : NetworkImage(backgroundUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  // Ícone de engrenagem no canto superior direito
                  Positioned(
                    top: 50,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(),
                          ),
                        );
                      },
                    ),
                  ),
                  // Avatar circular sobrepondo a capa e o corpo
                  Consumer<ProfileController>(
                    builder: (context, controller, child) {
                      return Positioned(
                        bottom: -50,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: controller.user != null
                              ? NetworkImage(controller.user!.avatarUrl)
                              : null,
                          child: controller.user == null
                              ? CircularProgressIndicator()
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Nome e Bio com dados dinâmicos
              Consumer<ProfileController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return CircularProgressIndicator(); // Exibe um loading enquanto os dados estão carregando
                  }

                  if (controller.user == null) {
                    return Text("Erro ao carregar dados do perfil");
                  }

                  return Column(
                    children: [
                      Text(
                        controller.user!.name, // Nome dinâmico do usuário
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          controller.user!.bio, // Biografia do usuário
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: const [
                  Tab(text: 'Fotos'),
                  Tab(text: 'Vídeos'),
                ],
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Consumer<ProfileController>(
                      builder: (context, controller, child) {
                        if (controller.isLoading || controller.user == null) {
                          return Center(child: CircularProgressIndicator());
                        } else if (controller.user!.photos.length == 0) {
                          return Center(
                            child: Text(
                                'Este usuario não possui nenhuma publicação.'),
                          );
                        }

                        // Exibindo os crumbs (fotos) do usuário
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: GridView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1,
                              ),
                              itemCount: controller.user!.photos.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    // Imagem de fundo com opacidade
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              controller.user!.photos[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // Camada de opacidade escura
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.black.withOpacity(
                                            0.9), // Cor preta com 50% de opacidade
                                      ),
                                    ),
                                    // Texto sobre a imagem
                                    // ignore: prefer_const_constructors
                                    Positioned(
                                      bottom: 10, // Posição do texto
                                      left: 10, // Alinhamento do texto
                                      // ignore: prefer_const_constructors
                                      child: Text(
                                        controller.user!.street[index],
                                        // ignore: prefer_const_constructors
                                        style: TextStyle(
                                          color: Colors.white, // Cor do texto
                                          fontSize: 8, // Tamanho da fonte
                                          fontWeight:
                                              FontWeight.bold, // Negrito
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        );
                      },
                    ),
                    Center(
                      child: Text(
                        'Vídeos em breve',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
