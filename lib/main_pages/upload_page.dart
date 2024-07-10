// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class VideoMetadataForm extends StatefulWidget {
  final String videoPath;

  const VideoMetadataForm({Key? key, required this.videoPath}) : super(key: key);

  @override
  _VideoMetadataFormState createState() => _VideoMetadataFormState();
}

class _VideoMetadataFormState extends State<VideoMetadataForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _category = '';
  bool _isUploading = false;

Future<void> _uploadVideo(String title, String description, String category) async {
  setState(() {
    _isUploading = true;
  });

  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      File videoFile = File(widget.videoPath);

      // Upload video to Firebase Storage
      String orderNumber = await _getNextFileName(user.uid);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      
      Position position = await _getCurrentLocation();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      String location = "${placemarks[0].locality}, ${placemarks[0].isoCountryCode}";

      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('Videos/${user.uid}/$fileName.mp4');

      UploadTask uploadTask = storageRef.putFile(videoFile);
      TaskSnapshot storageSnapshot = await uploadTask;
      String videoUrl = await storageSnapshot.ref.getDownloadURL();

      // Upload video metadata to Firebase Realtime Database
      DatabaseReference databaseRef = FirebaseDatabase.instance
          .ref('/Videos/$orderNumber');

      await databaseRef.update({
        'videoUrl': videoUrl,
        'title': title,
        'description': description,
        'category': category,
        'location' : location,
        'uid' : user.uid,
        'uploadTime': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully')),
      );
    }
  } catch (e) {
    debugPrint("Error uploading video: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error uploading video: $e')),
    );
  } finally {
    setState(() {
      _isUploading = false;
    });
  }
}

  Future<String> _getNextFileName(String uid) async {
    var snapshot = await FirebaseDatabase.instance.ref('/Videos/').once();
    print(snapshot.snapshot.value);

    // Check if snapshot value is null or notc a Map
    if (snapshot.snapshot.value == null) {
      return '0';
    }
    
    // Get the number of children under the Videos/$uid node
    int videoCount = (snapshot.snapshot.value as List).length;
    
    // Return a string representation of the next available index
    return '${videoCount}';
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Video Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (value) {
                  setState(() {
                    _category = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _uploadVideo(_title, _description, _category);
                  }
                },
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Upload Video'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
