import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image/image.dart' as Img;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FaceDetection(title: 'Flutter Demo Home Page'),
    );
  }
}

class FaceDetection extends StatefulWidget {
  FaceDetection({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _FaceDetectionState createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  int _counter = 0;
  ImageProvider image;

  @override
  Widget build(BuildContext context) {
    FaceDetector f = FirebaseVision.instance.faceDetector();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          child: Container(
        child: image != null ? Image(image: image) : Text("hello world"),
      )),
      floatingActionButton: SpeedDial(
        child: Icon(Icons.add),
        children: [
          SpeedDialChild(child: Icon(Icons.camera), onTap: pickImageFromCamera),
          SpeedDialChild(child: Icon(Icons.image), onTap: pickImageFromGallery),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  pickImageFromGallery() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 600, maxWidth: 800);
    doFaceDetection(file);
  }

  pickImageFromCamera() async {
    var file = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 600, maxWidth: 800);
    doFaceDetection(file);
  }

  doFaceDetection(File file) async {
    FaceDetector detector = FirebaseVision.instance.faceDetector(FaceDetectorOptions(enableClassification: true, enableContours: true, enableLandmarks: true, mode: FaceDetectorMode.accurate));
    var firebaseVisionImage = FirebaseVisionImage.fromFile(file);
    var faces = await detector.processImage(firebaseVisionImage);
    faces.forEach((face) {
      print(face.boundingBox);
    });

    Img.Image _image = Img.decodeImage(file.readAsBytesSync());
    for (Face face in faces) {
      var boundingBox = face.boundingBox;
      Img.drawRect(_image, boundingBox.left.round(), boundingBox.top.round(), boundingBox.right.round(), boundingBox.bottom.round(), Colors.blue.value);
      var points = face.getContour(FaceContourType.allPoints).positionsList;

      for (Offset point in points) {
        Img.drawRect(_image, point.dx.round(), point.dy.round(), point.dx.round() + 2 , point.dy.round() + 2, Colors.red.value);
      }
    }
    setState(() {
      image = MemoryImage(Img.encodeJpg(_image));
    });
  }
}
