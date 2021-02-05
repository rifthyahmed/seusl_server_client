import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TesseractClient extends StatefulWidget {
  TesseractClient({Key key}) : super(key: key);

  @override
  _TesseractClientState createState() => _TesseractClientState();
}

class _TesseractClientState extends State<TesseractClient> {
  String serverURL = "http://35.239.255.24:8080/api_server/api/upload";
  Dio dio = new Dio();
  File _image;
  final picker = ImagePicker();
  String _scannedText = "";

  Future _getImage() async {
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
        _scannedText = "";
      }
    });
  }

  Future sendImage() async {
    if (_image != null) {
      FormData formData = new FormData.fromMap({
        'image': await MultipartFile.fromFile(_image.path,
            filename: _image.path.split('/').last)
      });
      try {
        dio.post(serverURL, data: formData).then((response) => {
              if (response.statusCode == 200)
                {
                  setState(() {
                    _scannedText = response.data;
                  })
                }
            });
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(top: 20),
                child: getScennedText()),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'Upload the image',
              ),
            ),
            Container(
              width: 200,
              child: FlatButton(
                  onPressed: () => {_getImage()},
                  color: Colors.teal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("Upload"),
                      )
                    ],
                  )),
            ),
            _image == null
                ? Text("No image Selected")
                : Container(height: 200, child: Image.file(_image)),
            Container(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FlatButton(
                    onPressed: () => {sendImage()},
                    color: Colors.blueAccent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text("Send Image"),
                        )
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getScennedText() {
    if (_scannedText.length != 0) {
      return Text(
        _scannedText,
        style: TextStyle(color: Colors.black, fontSize: 15),
      );
    } else {
      return Container();
    }
  }
}
