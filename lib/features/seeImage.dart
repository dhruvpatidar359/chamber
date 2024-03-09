import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SeeImage extends StatelessWidget {
  const SeeImage({super.key, required this.imageFile, required this.tag});

  final File imageFile;
  final Object tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          imageFile.path.split('/').last,
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: Colors.black, fontSize: 20),
        ),
      ),
      body: Hero(
        tag: tag,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: InteractiveViewer(
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
