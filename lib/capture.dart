import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Capture extends StatefulWidget {
  const Capture({super.key});

  @override
  State<Capture> createState() => _CaptureState();
}

class _CaptureState extends State<Capture> {
  String imageUrl = '';
  GlobalKey<FormState> key = GlobalKey();
  TextEditingController description = TextEditingController();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('places');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Add Description & Images'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset("assets/tripitonlogo.png"),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: description,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                ),
                onPressed: () async {
                  ImagePicker imagePicker = ImagePicker();
                  XFile? file =
                      await imagePicker.pickImage(source: ImageSource.camera);
                  if (file == null) return;

                  String uniqueFileName =
                      DateTime.now().millisecondsSinceEpoch.toString();

                  Reference referenceRoot = FirebaseStorage.instance.ref();
                  Reference referenceDirImages = referenceRoot.child('images');
                  Reference referenceImageToUpload =
                      referenceDirImages.child(uniqueFileName);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Description and Image added successfully\n\t\t\t\tNow Press Submit Button'),
                    ),
                  );

                  try {
                    await referenceImageToUpload.putFile(File(file.path));
                    imageUrl = await referenceImageToUpload.getDownloadURL();
                  } catch (error) {}
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  String descriptionText = description.text;
                  Map<String, String> data = {
                    'description': descriptionText,
                    'image': imageUrl,
                  };
                  _reference.add(data);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 17.0, horizontal: 10.0),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
