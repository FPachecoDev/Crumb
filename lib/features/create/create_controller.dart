import 'dart:io';
import 'package:camera/camera.dart'; // Importa a biblioteca da câmera
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img; // Para manipulação de imagem
import 'package:geocoding/geocoding.dart'; // Para geocodificação

class CreatePageController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool isLoading = false;
  String? errorMessage;

  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  int selectedCameraIndex = 1; // 0 para traseira, 1 para frontal

  // Inicializa a câmera
  Future<void> initializeCamera() async {
    // Obtém a lista de câmeras disponíveis
    cameras = await availableCameras();

    // Inicializa a câmera com a frontal (índice 1 geralmente é a frontal)
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(
          cameras![selectedCameraIndex], ResolutionPreset.high);
      await _cameraController!.initialize();
      notifyListeners();
    }
  }

  // Alternar entre a câmera frontal e traseira
  Future<void> switchCamera() async {
    if (cameras == null || cameras!.isEmpty) return;

    selectedCameraIndex =
        selectedCameraIndex == 0 ? 1 : 0; // Alterna entre 0 e 1

    // Inicializa a nova câmera selecionada
    _cameraController =
        CameraController(cameras![selectedCameraIndex], ResolutionPreset.high);
    await _cameraController!.initialize();
    notifyListeners();
  }

  // Descartar o controller
  void disposeCamera() {
    _cameraController?.dispose(); // Libera o controller da câmera
    _cameraController = null; // Define como nulo
  }

  Future<void> saveMedia(File mediaFile, {required String caption}) async {
    isLoading = true;
    notifyListeners();

    try {
      // Verifica se o usuário está autenticado
      User? user = _auth.currentUser;
      if (user == null) {
        errorMessage = 'Usuário não autenticado';
        isLoading = false;
        notifyListeners();
        return;
      }

      // Obtém a localização atual do usuário
      Position position = await _getCurrentLocation();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      // Cria um mapa para os dados do crumb, incluindo a legenda
      Map<String, dynamic> crumbData = {
        'userId': user.uid,
        'mediaUrl': await _uploadMedia(mediaFile), // Salva o URL do arquivo
        'caption': caption, // Adiciona o campo de legenda (caption)
        "geopoint": GeoPoint(position.latitude, position.longitude),
        'street': place.street,
        'neighborhood': place.subLocality,
        'city': place.locality,
        'country': place.country,
        'postalCode': place.postalCode,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Salva o crumb no Firestore
      await _firestore.collection('crumbs').add(crumbData);

      isLoading = false;
      notifyListeners();
    } catch (error) {
      errorMessage = 'Ocorreu um erro: $error';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de localização está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Os serviços de localização estão desativados.');
    }

    // Verifica a permissão de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada permanentemente.');
    }

    // Retorna a posição atual do usuário
    return await Geolocator.getCurrentPosition();
  }

  Future<String> _uploadMedia(File mediaFile) async {
    String filePath =
        'crumbs/${DateTime.now().millisecondsSinceEpoch}_${mediaFile.uri.pathSegments.last}';
    final storageRef = _storage.ref().child(filePath);

    // Faz o upload do arquivo para o Firebase Storage
    await storageRef.putFile(mediaFile);
    String downloadUrl = await storageRef.getDownloadURL();

    return downloadUrl; // Retorna a URL do arquivo salvo
  }
}
