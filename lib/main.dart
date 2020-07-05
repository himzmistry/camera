import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;

void main() => runApp(DemoPro());

class DemoPro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  imageLib.Image _image;
  String fileName;
  Filter _filter;
  List<Filter> filters = presetFiltersList;
  File imageFile;

  Future getImageForFilter(context) async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    fileName = basename(imageFile.path);
    var image = imageLib.decodeImage(imageFile.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);
    Map imagefile = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new PhotoFilterSelector(
          title: Text("Photo Filter Example"),
          image: image,
          filters: filters,
          filename: fileName,
          loader: Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        imageFile = imagefile['image_filtered'];
      });
      print(imageFile.path);
    }
  }

  File _image1;

  var pickedImage;

  Future getImage(bool isCamera) async {
    if (isCamera) {
      ImagePicker.pickImage(source: ImageSource.camera)
          .then((File recordedImage) {
        if (recordedImage != null && recordedImage.path != null) {
          CircularProgressIndicator();
        }
        GallerySaver.saveImage(recordedImage.path).then((path) {
          print("Image saved");
        });
      });
    } else {
      pickedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        try {
          _image1 = pickedImage;
        } catch (exception) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.camera),
                        onPressed: () {
                          getImage(true);
                        }),
                    Text("Open camera"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.image),
                        onPressed: () => getImage(false)),
                    Text("View Images"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.import_export),
                        onPressed: () async {
                          await getImageForFilter(context);
                        }),
                    Text("Apply Filters"),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _image1 == null
                      ? Container()
                      : Image.file(
                          _image1,
                          height: 300,
                          width: 300,
                          fit: BoxFit.contain,
                        )
                ]),
          ),
          // Row(
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  imageFile == null
                      ? Center(
                          child: new Text('No image selected.'),
                        )
                      : Image.file(
                          imageFile,
                          height: 300,
                          width: 300,
                        ),
                ]),
          ),
          // )
        ],
      ),
    );
  }
}
