import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerClass extends StatefulWidget {
  const ImagePickerClass(this.imagePickFn, {Key key}) : super(key: key);

  final void Function(File pickedImage) imagePickFn;

  @override
  _ImagePickerClassState createState() => _ImagePickerClassState();
}

class _ImagePickerClassState extends State<ImagePickerClass> {
  File _image;
  Future getImagefromCamera() async {
    final image = ImagePicker();
    await image
        .getImage(source: ImageSource.camera)
        .then((value) => _image = File(value.path));
    setState(() {
      widget.imagePickFn(_image);
    });
  }

  Future getImagefromGallery() async {
    final image = ImagePicker();
    await image
        .getImage(source: ImageSource.gallery)
        .then((value) => _image = File(value.path));
    setState(() {
      widget.imagePickFn(_image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.5),
                borderRadius: BorderRadius.circular(22)),
            child: Center(
              child: _image == null
                  ? const Text('No Image is picked')
                  : Image.file(_image),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FloatingActionButton(
              onPressed: getImagefromCamera,
              heroTag: 'camera',
              child: const Icon(Icons.add_a_photo),
            ),
            FloatingActionButton(
              onPressed: getImagefromGallery,
              heroTag: 'gallery',
              child: const Icon(Icons.camera_alt),
            )
          ],
        )
      ],
    );
  }
}
