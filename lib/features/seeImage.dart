import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SeeImage extends StatelessWidget {
  SeeImage({required this.imageFile, required this.tag});

  final imageFile;
  final tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          imageFile.path.split('/').last,
          style: TextStyle(
              fontWeight: FontWeight.w700, color: Colors.black, fontSize: 20),
        ),
      ),
      body: Hero(
        tag: tag,
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: PhotoView(
            imageProvider: FileImage(imageFile),
          ),
        ),
      ),
    );
  }
}
