import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyHomeState();
  }
}

class MyHomeState extends State<MyHomePage> {
  File imageFiles;
  double _originalSize;
  double _afterCompress;
  final MEGABYTE = 1024 * 1024;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick & Crop'),
        centerTitle: true,
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              imageFiles == null
                  ? Text("Select an Image")
                  : Image.file(
                imageFiles,
                height: 250,
                width: 300,
              ),
              SizedBox(
                height: 30,
              ),
              _originalSize == null
                  ? Text('')
                  : Text(
                  'Original Size: ${_originalSize.toStringAsFixed(2)} MB'),
              _afterCompress == null
                  ? Text('')
                  : Text(
                  'Size after compress: ${_afterCompress.toStringAsFixed(2)} MB')
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: UniqueKey(),
            onPressed: () {
              _getImageFile(ImageSource.camera);
            },
            label: Text('Camera'),
            icon: Icon(Icons.camera),
          ),
          FloatingActionButton.extended(
            heroTag: UniqueKey(),
            onPressed: () {
              _getImageFile(ImageSource.gallery);
            },
            label: Text('Gallery'),
            icon: Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }

  void _getImageFile(ImageSource source) async {
    var tempFile = await ImagePicker.pickImage(source: source);

    setState(() {
      _originalSize = tempFile.lengthSync() / MEGABYTE;
    });
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: tempFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));

    var resultAfterCompress = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path, tempFile.path,
        quality: 60);

    setState(() {
      _afterCompress = resultAfterCompress.lengthSync() / MEGABYTE;
      imageFiles = resultAfterCompress;
    });
  }
}
