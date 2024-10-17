import 'dart:io';
import 'package:crumb/app.dart';
import 'package:crumb/features/create/create_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  File? _videoFile;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isRecording = false;
  bool _isLoading = false; // Estado de loading
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  TextEditingController _captionController =
      TextEditingController(); // Controlador para a legenda

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _selectedCameraIndex = 0; // Começa com a câmera traseira
    _startCamera(_cameras![_selectedCameraIndex]);
  }

  Future<void> _startCamera(CameraDescription cameraDescription) async {
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller!.initialize().then((_) {
      setState(() {}); // Atualiza a UI assim que a câmera for inicializada
    }).catchError((error) {
      print('Erro na inicialização da câmera: $error');
    });
  }

  Future<void> _takePhoto() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        await _initializeControllerFuture;
        final image = await _controller!.takePicture();
        setState(() {
          _imageFile = File(image.path);
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _recordVideo() async {
    if (_controller != null && _controller!.value.isInitialized) {
      if (_isRecording) {
        final video = await _controller!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _videoFile = File(video.path);
        });
      } else {
        await _controller!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      }
    }
  }

  Future<void> _confirmSelection() async {
    setState(() {
      _isLoading = true; // Exibe o loading ao iniciar
    });

    final controller =
        Provider.of<CreatePageController>(context, listen: false);

    if (_imageFile != null) {
      await controller.saveMedia(_imageFile!, caption: _captionController.text);
    } else if (_videoFile != null) {
      await controller.saveMedia(_videoFile!, caption: _captionController.text);
    }

    setState(() {
      _isLoading = false; // Remove o loading após a publicação
    });

    if (controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto/Vídeo salvo com sucesso!")),
      );

      // Redireciona para a página principal após o sucesso
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => App()),
      );
    }

    setState(() {
      _imageFile = null;
      _videoFile = null;
      _captionController.clear(); // Limpa o campo de legenda
    });
    _initializeCamera();
  }

  void _retake() {
    setState(() {
      _imageFile = null;
      _videoFile = null;
      _captionController.clear(); // Limpa o campo de legenda
    });
    _initializeCamera();
  }

  void _toggleCamera() {
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    _startCamera(_cameras![_selectedCameraIndex]);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _captionController.dispose(); // Dispose do controlador de legenda
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _imageFile != null || _videoFile != null
              ? _buildPreview()
              : Padding(
                  padding: const EdgeInsets.only(top: 51, left: 10, right: 10),
                  child: Container(child: _buildCameraView()),
                ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // Fundo transparente
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return _controller == null || !_controller!.value.isInitialized
        ? const Center(
            child: CircularProgressIndicator(
            color: Colors.white,
          ))
        : Stack(
            children: [
              ClipRRect(
                // ignore: prefer_const_constructors
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                ),
                child: CameraPreview(_controller!),
              ),
              Positioned(
                bottom: 15,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _takePhoto,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey, // Set border color
                              width: 2),
                        ),
                        height: 70,
                        width: 70,
                      ),
                    ),
                    // IconButton(
                    //  icon: const Icon(
                    //    Icons.camera,
                    //   color: Colors.white,
                    //   size: 60,
                    //  ),
                    //  onPressed: _takePhoto,
                    // ),
                    //  IconButton(
                    //  icon: Icon(
                    //    _isRecording ? Icons.stop : Icons.videocam,
                    //    color: _isRecording ? Colors.red : Colors.white,
                    //    size: 50,
                    //   ),
                    //    onPressed: _recordVideo,
                    //  ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 40,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => App()),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.switch_camera,
                    size: 40,
                    color: Colors.white,
                  ),
                  onPressed: _toggleCamera,
                ),
              ),
            ],
          );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        Stack(
          children: [
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 51),
                child: ClipRRect(
                  // ignore: prefer_const_constructors
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  ),
                  child: Image.file(
                    _imageFile!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else if (_videoFile != null)
              Center(
                child: Text("Vídeo gravado: ${_videoFile!.path}"),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            controller: _captionController,
            decoration: InputDecoration(
              hintText: 'Escreva uma legenda...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: _confirmSelection,
              // ignore: prefer_const_constructors
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            InkWell(
              onTap: _retake,
              // ignore: prefer_const_constructors
              child: Icon(
                Icons.cancel,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
