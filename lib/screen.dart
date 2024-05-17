// ignore_for_file: camel_case_types

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_picker/gallery_picker.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class imagetoText extends StatefulWidget {
  const imagetoText({
    super.key,
  });

  @override
  State<imagetoText> createState() => _imagetoTextState();
}

class _imagetoTextState extends State<imagetoText> {
  File? selectedMedia;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Text Recognition",
        ),
      ),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<MediaFile>? media = await GalleryPicker.pickMedia(
              context: context, singleMedia: true);
          if (media != null && media.isNotEmpty) {
            var data = await media.first.getFile();
            setState(() {
              selectedMedia = data;
            });
          }
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _imageView(),
        _extractTextView(),
        _otherPickers(),
      ],
    );
  }

  Widget _imageView() {
    if (selectedMedia == null) {
      return const Center(
        child: Text("Pick an image for text recognition."),
      );
    }
    return Center(
      child: Image.file(
        selectedMedia!,
        width: 200,
      ),
    );
  }

  Widget _extractTextView() {
    if (selectedMedia == null) {
      return const Center(
        child: Text("No result."),
      );
    }
    return FutureBuilder(
      future: _extractText(selectedMedia!),
      builder: (context, snapshot) {
        return Text(snapshot.data ?? "",
            style: const TextStyle(
              fontSize: 25,
            ));
      },
    );
  }

  Widget _otherPickers() {
    return Column(
      children: [
        MaterialButton(
          color: Colors.red,
          child: const Text("Pick Image from Camera"),
          onPressed: () {
            _pickImageFromCamera();
          },
        ),
        MaterialButton(
          color: Colors.blue,
          child: const Text("Pick Image from Gallery"),
          onPressed: () {
            _pickImageFromGallery();
          },
        ),
      ],
    );
  }

  Future<String?> _extractText(File file) async {
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
    final InputImage inputImage = InputImage.fromFile(file);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    String text = recognizedText.text;
    textRecognizer.close();
    return text;
  }

  Future _pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage == null) return;
    setState(() {
      selectedMedia = File(returnedImage.path);
    });
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) return;
    setState(() {
      selectedMedia = File(returnedImage.path);
    });
  }
}