import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_view/photo_view.dart';

class ImageProcessing extends StatefulWidget {
  const ImageProcessing({super.key, required this.imageFile});
  final XFile imageFile;
  @override
  State<ImageProcessing> createState() => _ImageProcessingState();
}

class _ImageProcessingState extends State<ImageProcessing> {
  // late CroppedFile croppedFileOutput;
  Directory directory = Directory("/data/data/com.example.chamber/images");
  File? _processedImage;

  @override
  void initState() {
    // TODO: implement initState
    callCropper();
    super.initState();
  }

  Future<void> callCropper() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    // croppedFileOutput = croppedFile!;

    print(croppedFile);
    if (croppedFile != null) {
      print(croppedFile.path);
      print("path ha bhai");
      await processImage(croppedFile);
      // await FileSaver.instance.saveFile(file: croppedFile.,);
    }

    // Rename (move) the cropped file to the destination directory
  }

  Future<void> processImage(CroppedFile _selectedImage) async {
    // Get the original filename without the path and extension
    String originalFilenameWithoutExtension =
        widget.imageFile.path.split('/').last.split('.').first;

// Rename the file to have a .jpeg extension
//     String renamedFilename = '$originalFilenameWithoutExtension.jpeg';
//     File img = File(widget.imageFile.path);
//
//     final image = i.decodeImage(img.readAsBytesSync())!;
//     print(originalFilenameWithoutExtension);
//     File(img.path + ".jpeg").writeAsBytesSync(i.encodeJpg(image));

// Save the renamed file
//     final v = await widget.imageFile
//         .rename('path/to/your/save/location/$renamedFilename');
//     print(v);

    var request = http.MultipartRequest(
        'POST', Uri.parse('https://chamber.pythonanywhere.com/upload'));
    request.files
        .add(await http.MultipartFile.fromPath('file', _selectedImage.path));

    http.StreamedResponse response = await request.send();
    print(response.stream);

    // Check if the request was successful
    if (response.statusCode == 200) {
      ByteStream byteStream = response.stream;

      // Convert the byte stream to a Uint8List
      Uint8List byteList = await byteStream.toBytes();

      // Save the Uint8List as a file
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

// Create a unique filename by combining the original filename and timestamp
      String uniqueFilename = '${originalFilenameWithoutExtension}_$timestamp';

// Specify the path with the unique filename
      String filePath = '/data/data/com.example.chamber/images/$uniqueFilename';

// Write the image data to the file
      await File(filePath).writeAsBytes(byteList);
      // Update the UI
      _processedImage = File(filePath);
      print("Done");
      setState(() {});
    } else {
      // Handle error
      print('Error: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Processing'),
      ),
      body: Center(
        child: _processedImage != null
            ? Image.file(
                _processedImage!,
                fit: BoxFit.cover,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.threeArchedCircle(
                      color: Colors.black87, size: 36),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Processing Image...",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
