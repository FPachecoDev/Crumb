import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CreatePageController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  RxBool isLoading = false.obs;
  String? errorMessage;
  CameraController? cameraController;
  Rx<File?> imageFile = Rx<File?>(null);
  Rx<File?> videoFile = Rx<File?>(null);
  int selectedCameraIndex = 0;
  TextEditingController captionController = TextEditingController();

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      selectedCameraIndex = 0;
      cameraController =
          CameraController(cameras[selectedCameraIndex], ResolutionPreset.high);
      await cameraController!.initialize();
      update();
    } catch (e) {
      errorMessage = 'Erro ao inicializar a câmera: $e';
      update();
    }
  }

  Future<void> takePhoto() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      final image = await cameraController!.takePicture();
      imageFile.value = File(image.path);
    }
  }

  Future<void> toggleCamera() async {
    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;
    await initializeCamera();
  }

  Future<void> confirmSelection() async {
    isLoading.value = true;
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        errorMessage = 'Usuário não autenticado';
        isLoading.value = false;
        return;
      }

      // Obtém localização e salva mídia no Firestore
      Position position = await _getCurrentLocation();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      String mediaUrl = await _uploadMedia(imageFile.value!);

      Map<String, dynamic> crumbData = {
        'userId': user.uid,
        'mediaUrl': mediaUrl,
        'caption': captionController.text,
        "geopoint": GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('crumbs').add(crumbData);
      imageFile.value = null;
      videoFile.value = null;
      captionController.clear();
      isLoading.value = false;
    } catch (e) {
      errorMessage = 'Erro ao salvar mídia: $e';
      isLoading.value = false;
    }
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> _uploadMedia(File file) async {
    // Lógica para salvar no Firebase Storage e retornar a URL do arquivo.
    // Exemplo:
    String fileName = 'media/${DateTime.now()}.png';
    await _storage.ref(fileName).putFile(file);
    return await _storage.ref(fileName).getDownloadURL();
  }

  void retake() {
    imageFile.value = null;
    videoFile.value = null;
    captionController.clear();
    initializeCamera();
  }
}
