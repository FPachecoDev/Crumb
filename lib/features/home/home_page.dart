import 'dart:ui';

import 'package:crumb/features/home/models/crumbs_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _locationPermissionGranted = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showLocationDialog();
    } else {
      setState(() {
        _locationPermissionGranted = true;
      });
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition();
    if (_currentPosition != null) {
      // Carregar os crumbs quando a localização é obtida
      Provider.of<HomePageController>(context, listen: false)
          .loadCrumbs(_currentPosition!);
    }
  }

  @override
  void dispose() {
    // Limpeza ou cancelamento de operações ativas, se necessário
    super.dispose();
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissão de Localização'),
          content: const Text(
              'Este aplicativo precisa acessar sua localização. Você aceita?'),
          actions: [
            TextButton(
              onPressed: () async {
                LocationPermission permission =
                    await Geolocator.requestPermission();
                if (permission == LocationPermission.whileInUse ||
                    permission == LocationPermission.always) {
                  setState(() {
                    _locationPermissionGranted = true;
                  });
                  _getCurrentLocation();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Sim'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Não'),
            ),
          ],
        );
      },
    );
  }

  // Função para formatar o tempo passado desde o timestamp
  String _timeAgo(DateTime? timestamp) {
    if (timestamp == null) return "Data desconhecida";

    final Duration difference = DateTime.now().difference(timestamp);

    if (difference.inDays > 1) {
      return "${difference.inDays}d";
    } else if (difference.inHours >= 1) {
      return "${difference.inHours}h";
    } else if (difference.inMinutes >= 1) {
      return "${difference.inMinutes}m";
    } else {
      return "Agora";
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<HomePageController>(
          builder: (context, homeController, child) {
            if (homeController.isLoading) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.white,
              ));
            }

            if (homeController.crumbs.isEmpty) {
              return const Center(
                  child: Text(
                "Nenhum crumb encontrado nas proximidades",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ));
            }

            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: homeController.crumbs.length,
              itemBuilder: (context, index) {
                final CrumbModel crumb = homeController.crumbs[index];
                return FutureBuilder<Map<String, String>>(
                  future: homeController.getUserDetails(crumb.userId),
                  builder: (context, snapshot) {
                    String nickname = 'Usuário';
                    String avatarUrl =
                        'https://someimageurl.com/profile.png'; // URL padrão

                    if (snapshot.connectionState == ConnectionState.done) {
                      nickname = snapshot.data?['nickname'] ?? 'Usuário';
                      avatarUrl = snapshot.data?['avatarUrl'] ??
                          avatarUrl; // Atualiza o avatarUrl
                    }

                    bool isRemembered =
                        homeController.isCrumbRemembered(crumb.id);

                    int rememberCount =
                        homeController.getRememberCount(crumb.id);

                    return Stack(
                      children: [
                        // Imagem de fundo
                        Image.network(
                          crumb.mediaUrl,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                        Positioned(
                          bottom: 60,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          avatarUrl), // Imagem do perfil do usuário
                                    ),
                                    Text(
                                      " $nickname",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                        width:
                                            10), // Espaço entre o nickname e o timestamp
                                    Text(
                                      _timeAgo(crumb
                                          .timestamp), // Exibindo o tempo calculado
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ],
                                ),
                                crumb.caption == ''
                                    // ignore: prefer_const_constructors
                                    ? SizedBox(
                                        height: 10,
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Text(
                                          crumb.caption,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                Text(
                                  "${crumb.city}, ${crumb.country}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 15, right: 10),
                                  child: InkWell(
                                    onTap: () {
                                      homeController.toggleRememberCrumb(
                                          crumb.id, crumb.userId);
                                    },
                                    child: Container(
                                        child: isRemembered
                                            ? Image.asset(
                                                'assets/images/icon/icon_remender_full.png',
                                                width: 29,
                                              )
                                            : Image.asset(
                                                'assets/images/icon/icon_remender_linha.png',
                                                width: 29,
                                              )),
                                  ),
                                ),
                                // Implementando as condições de contagem
                                if (isRemembered && rememberCount > 0) ...[
                                  Text(
                                    rememberCount == 1
                                        ? "$rememberCount pessoa reviveu esta memória."
                                        : "$rememberCount pessoas reviveram esta memória.",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ] else ...[
                                  const SizedBox
                                      .shrink(), // Retorna um widget vazio se não houver contagem
                                ]
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
