
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'AboutPage.dart';
import 'dart:typed_data';
import 'package:tflite/tflite.dart';

// Loading the Tensorflow model here
loadModel() async {
  await Tflite.loadModel(
    model: 'assets/LENET.tflite',
    labels: 'assets/labels.txt'
  );
}

// Image classification function here
classifyImage(image) async {
  var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 5,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
  );

  setState(() {
    _output = output!;
    _loading = false;
  });
}

// Main function starts here
void main() => runApp(MyApp(
));

// All the app stuffs are here
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute:'a',
      routes: {
        'a': (context) => MyHomePage(),
        'b': (context) => AboutPage()

      },
      title: 'Prachalit Lipi',
      theme: ThemeData(
        backgroundColor: Colors.blueGrey,

      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image;
  bool progress = false;
  bool _imagesubmitted = false;


  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if(image == null) return;

      final imageTemp = File(image.path);
      _cropImage(imageTemp.path);
      setState(() => this.image = imageTemp);

      //cropping of image
    } on PlatformException catch(e) {
      print('Failed to pick image: $e');
    }

  }
  Future pickImagefromCamera() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,

      );

      if(image == null) return;

      final imageTemp = File(image.path);

      setState(() {
        this.image = imageTemp;
      });
      _cropImage(image.path);
    } on PlatformException catch(e) {
      print('Failed to pick image: $e');
    }

  }
  _cropImage(filePath) async {
    File? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Image Cropper',
        toolbarColor: Colors.green[700],
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: Colors.green[700],
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (croppedImage != null) {
      image = croppedImage;
      setState(() {});
    }
  }
  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit the App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () =>
                exit(0),//outside the app
            child: const Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }


  @override
  Widget build(BuildContext context) {
    bool _imagesubmitted = false;
    Future<bool> popout() async {
      return (await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Prediction'),
          content: const Text('A'),
          actions: <Widget>[

            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, 'a'),//outside the app
              child: Center(child: const Text('OK')),
            ),
          ],
        ),
      )) ?? false;
    }

    // Function taking the image in
    void _submitImage(image)  {
       classifyImage(image);
       popout();
    };
    bool _conditionMet = false;
    void _checkCondition() {
      if (image==null) {
        _conditionMet = false;
      }
      else{
        _conditionMet = true;
      }
    }
    return WillPopScope(
    onWillPop: _onWillPop,
    child: RefreshIndicator(
    onRefresh: test,

    child: Scaffold(
    backgroundColor:Colors.grey,

    appBar: AppBar(

    title: const Center(child: Text("Upload Image",

    selectionColor: Color(0xFF00008B),
    style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
    ),
    )),
    leading: IconButton(
    color: Colors.black,
    icon: const Icon(Icons.refresh),
    onPressed: () {
    Navigator.pushNamed(context, 'a');
    },

    ),



    backgroundColor: const Color(0xFF6132a8),


    ),
    body: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    const Center(

    ),
    Padding(
    padding: const EdgeInsets.all(16.0),
    child: Container(
    width: MediaQuery.of(context).size.width,
    height: 200.0,
    child: Center(

   child:image == null
       ? Text("No Image is picked")
       : Image.file(image!),

    ),
    ),
    ),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
    FloatingActionButton(
    backgroundColor: Color(0xFF6132a8),
    onPressed: pickImage,
    tooltip: "Pick Image From Gallery",
    child: Icon(Icons.folder),
    ),
    FloatingActionButton(
    backgroundColor: Color(0xFF6132a8),
    onPressed: pickImagefromCamera,
    tooltip: "Pick Image From Camera",
    child: const Icon(Icons.camera_alt),
    )
    ],
    ),
    const SizedBox(
    height: 30,
    ),
   Column(
     children: [
       CupertinoButton(
         child: const Text('Predict',
             style: TextStyle(
               color: Color(0xFF6132a8),
             ),
           ),
           onPressed:  () {
             if(image == null) {

               return null;

             }

             _submitImage(image);
       },

       ),
     ],
   ),

    Padding(

    padding:  EdgeInsets.only(left: 180.0,top: 30.0),

    child: FloatingActionButton(


    backgroundColor: Color(0xFF6132a8),
    tooltip: 'Help',
    child: Icon(Icons.question_mark_outlined),
    onPressed: () {

    Navigator.pushNamed(context, 'b');
    },

    ),
    ),
    ],



    ),


    ),


    ),



    );

  }
  showAlertDialog(BuildContext context,String x) {
    double h = MediaQuery
        .of(context)
        .size
        .height;
    double w = MediaQuery
        .of(context)
        .size
        .width;

    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,

      elevation: 0,

      title: Text("Predicted Text"),
      content: GestureDetector(
        onTap: () => null,
        child: Container(
          //     color: Colors.blue,
            height: h,
            width: w,
            child: Text(
              x, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)
        ),
      ),

      actions: [
        TextButton(onPressed: () {
          Navigator.pushNamed(context, 'a');

        },
          child: Text('OK'),),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 10), () {

        });
        return alert;
      },

    );
  }
  Future<String> test () async {
    return Future.delayed(
      Duration(microseconds: 10),


    );


  }


}


