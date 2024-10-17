import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'create_controller.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final ImagePicker _picker = ImagePicker();
  final CreatePageController controller = Get.put(CreatePageController());

  @override
  void initState() {
    super.initState();
    controller.initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        return Stack(
          children: [
            controller.imageFile != null || controller.videoFile != null
                ? _buildPreview()
                : Padding(
                    padding:
                        const EdgeInsets.only(top: 51, left: 10, right: 10),
                    child: Container(child: _buildCameraView()),
                  ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildCameraView() {
    return controller.cameraController == null ||
            !controller.cameraController!.value.isInitialized
        ? const Center(
            child: CircularProgressIndicator(
            color: Colors.white,
          ))
        : Stack(
            children: [
              CameraPreview(controller.cameraController!),
              Positioned(
                bottom: 15,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: controller.takePhoto,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        height: 70,
                        width: 70,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 40, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.switch_camera,
                      size: 40, color: Colors.white),
                  onPressed: controller.toggleCamera,
                ),
              ),
            ],
          );
  }

  Widget _buildPreview() {
    return Stack(
      children: [
        if (controller.imageFile.value != null)
          Image.file(controller.imageFile.value!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover)
        else if (controller.videoFile.value != null)
          Center(
              child:
                  Text("Vídeo gravado: ${controller.videoFile.value!.path}")),
        Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: TextField(
            controller: controller.captionController,
            decoration: const InputDecoration(
              hintText: 'Escreva uma legenda...',
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: controller.confirmSelection,
                child: const Text('Aceitar'),
              ),
              ElevatedButton(
                onPressed: controller.retake,
                child: const Text('Refazer'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
