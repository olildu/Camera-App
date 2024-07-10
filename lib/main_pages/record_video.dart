import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_assignment/main_pages/upload_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

// Initialize Firebase
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CameraApp(),
    );
  }
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController? controller;
  late List<CameraDescription> _cameras;
  bool _isRecording = false;
  bool initializedCamera = false;

  Future<void> startCamera() async {
    if (!initializedCamera) {
      WidgetsFlutterBinding.ensureInitialized();
      _cameras = await availableCameras();
      controller = CameraController(_cameras[0], ResolutionPreset.max);
      await controller!.initialize();
      initializedCamera = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    startCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _toggleRecord() async {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });
      XFile videoFile = await controller!.stopVideoRecording();
      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await videoFile.saveTo(path);
      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.DefaultQuality, 
        deleteOrigin: false, // It's false by default
      );

      print(mediaInfo!.file!.path);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideoMetadataForm(videoPath: path)),
      );
    } else {
      setState(() {
        _isRecording = true;
      });
      await controller!.startVideoRecording();
      print('Recording started');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record your Videos'),
      ),
      body: FutureBuilder<void>(
        future: startCamera(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || controller == null || !controller!.value.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: 300,
                          height: 500,
                          child: CameraPreview(controller!),
                        ),
                      ),
                      const SizedBox(height: 50),
                      GestureDetector(
                        onTap: _toggleRecord,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRecording
                                  ? Colors.red
                                  : const Color.fromARGB(255, 250, 85, 73),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

