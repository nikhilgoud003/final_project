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
        title: const Text('Add Description & Images '),
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
                  // Open camera or gallery
                  ImagePicker imagePicker = ImagePicker();
                  XFile? file =
                      await imagePicker.pickImage(source: ImageSource.camera);
                  //print('${file?.path}');
                  if (file == null) return;

                  // Create unique file name
                  String uniqueFileName =
                      DateTime.now().millisecondsSinceEpoch.toString();

                  // Upload image to Firebase
                  Reference referenceRoot = FirebaseStorage.instance.ref();
                  Reference referenceDirImages = referenceRoot.child('images');

                  // Create reference for image to be stored in Firebase
                  Reference referenceImageToUpload =
                      referenceDirImages.child(uniqueFileName);
                  SnackBar snackBar = const SnackBar(
                    content: Text(
                        'Description and Image added successfully\n\t\t\t\tNow Press Submit Button'),
                  );
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  try {
                    // Store the file
                    await referenceImageToUpload.putFile(File(file.path));
                    imageUrl = await referenceImageToUpload.getDownloadURL();
                  } catch (error) {
                    // print(error);
                  }
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
