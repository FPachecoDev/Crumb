// lib/features/global/ui/global_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crumb/features/global/global_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:crumb/features/global/model/global_crumb_model.dart';

class GlobalPage extends StatefulWidget {
  @override
  _GlobalPageState createState() => _GlobalPageState();
}

class _GlobalPageState extends State<GlobalPage> {
  late GoogleMapController mapController;
  LatLng? _currentPosition; // Para armazenar a posição atual
  double _currentZoom = 18.0; // Zoom inicial
  bool _isLoading = true; // Para controlar o estado de carregamento
  Set<Marker> _markers = {}; // Para armazenar os marcadores

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation(); // Chama a função para obter a localização atual
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Verifica se as permissões de localização estão concedidas
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Se as permissões foram negadas, solicita-as
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Obtém a posição atual do usuário
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _currentPosition = LatLng(position.latitude,
              position.longitude); // Atualiza a posição atual
          _isLoading = false; // Define o estado de carregamento como falso
        });
        _fetchCrumbs(); // Chama o método para buscar crumbs
      } else {
        print('Permissão de localização negada');
        setState(() {
          _isLoading =
              false; // Define o estado de carregamento como falso mesmo se a permissão for negada
        });
      }
    } catch (e) {
      print("Erro ao obter localização: $e");
      setState(() {
        _isLoading =
            false; // Define o estado de carregamento como falso em caso de erro
      });
    }
  }

  void _fetchCrumbs() {
    final controller =
        context.read<GlobalController>(); // Usando read para não ouvir mudanças
    controller.fetchCrumbs().then((_) {
      _addMarkers(); // Adiciona os marcadores após buscar os crumbs
    }).catchError((error) {
      print('Erro ao buscar crumbs: $error');
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentPosition != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(
          _currentPosition!)); // Move a câmera para a posição atual
      _addMarkers(); // Adiciona os marcadores ao mapa
    }
  }

  void _addMarkers() {
    final controller =
        context.read<GlobalController>(); // Usando read para não ouvir mudanças
    _markers.clear(); // Limpa os marcadores existentes
    for (GlobalCrumbModel crumb in controller.crumbs) {
      _markers.add(
        Marker(
          markerId: MarkerId(crumb.id), // Certifique-se de que 'id' é único
          position: LatLng(
            crumb.geopoint.latitude,
            crumb.geopoint.longitude,
          ), // Use as coordenadas de cada crumb
          infoWindow: InfoWindow(
            title: crumb.userId,
            snippet: crumb.caption,
          ),
        ),
      );
    }
    setState(
        () {}); // Atualiza o estado para que os marcadores apareçam no mapa
  }

  void _zoomIn() {
    setState(() {
      _currentZoom++;
      if (mapController != null) {
        mapController.animateCamera(CameraUpdate.zoomIn());
      }
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom--;
      if (mapController != null) {
        mapController.animateCamera(CameraUpdate.zoomOut());
      }
    });
  }

  @override
  void dispose() {
    mapController.dispose(); // Libera o controlador ao descartar o widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalController>(
      builder: (context, controller, child) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            body: Stack(
              children: [
                // Verifica se a localização atual foi obtida
                _isLoading || controller.isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      ) // Exibe um carregador enquanto aguarda a localização ou os crumbs
                    : GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition ??
                              LatLng(37.7749,
                                  -122.4194), // Usa uma posição padrão enquanto aguarda a localização
                          zoom: _currentZoom,
                        ),
                        markers: _markers, // Passa a lista de marcadores
                        zoomControlsEnabled: false,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                Positioned(
                  bottom: 50,
                  right: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: _zoomIn,
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: _zoomOut,
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
