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

  CameraController? _cameraController; // Adiciona o CameraController
  List<CameraDescription>? cameras;

  // Inicializa a câmera
  Future<void> initializeCamera() async {
    // Obtém a lista de câmeras disponíveis
    cameras = await availableCameras();

    // Inicializa o controller com a primeira câmera
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(cameras![0], ResolutionPreset.high);
      await _cameraController!.initialize();
      notifyListeners();
    }
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

      // Reduz a qualidade da imagem e força a orientação para "de pé"
      File compressedFile = await _compressImage(mediaFile);

      // Cria um mapa para os dados do crumb, incluindo a legenda
      Map<String, dynamic> crumbData = {
        'userId': user.uid,
        'mediaUrl':
            await _uploadMedia(compressedFile), // Salva o URL do arquivo
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

  Future<File> _compressImage(File mediaFile) async {
    // Lê a imagem original
    final img.Image originalImage =
        img.decodeImage(await mediaFile.readAsBytes())!;

    // Gira a imagem para que fique na orientação "de pé"
    final img.Image orientedImage = img.copyRotate(
        originalImage, 90); // Gira 90 graus, ajuste conforme necessário

    // Reduz a qualidade da imagem (por exemplo, para 50% do tamanho original)
    final img.Image resizedImage = img.copyResize(orientedImage,
        width: (orientedImage.width * 0.5).round());

    // Salva a imagem comprimida em um arquivo temporário
    final compressedFile =
        File(mediaFile.path.replaceFirst(RegExp(r'\.\w+$'), '_compressed.jpg'))
          ..writeAsBytesSync(img.encodeJpg(resizedImage,
              quality: 85)); // Ajuste a qualidade conforme necessário

    return compressedFile;
  }
}
