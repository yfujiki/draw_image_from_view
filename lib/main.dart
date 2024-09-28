import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Capture Widget as Image')),
        body: const CaptureWidgetExample(),
      ),
    );
  }
}

class CaptureWidgetExample extends StatefulWidget {
  const CaptureWidgetExample({super.key});

  @override
  CaptureWidgetExampleState createState() => CaptureWidgetExampleState();
}

class CaptureWidgetExampleState extends State<CaptureWidgetExample> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _capturePng() async {
    try {
      // Obtain the image data from the RepaintBoundary
      RenderRepaintBoundary? boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      ui.Image? image = await boundary.toImage(pixelRatio: 4.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? pngBytes = byteData?.buffer.asUint8List();
      if (pngBytes == null) {
        if (kDebugMode) {
          print("No image bytes");
        }
        return;
      }

      // Request storage permissions
      var status = await Permission.photos.request();
      if (status.isGranted) {
        final result = await ImageGallerySaver.saveImage(pngBytes);
        if (result['isSuccess']) {
          if (kDebugMode) {
            print('Screenshot saved to gallery');
          }
        } else {
          if (kDebugMode) {
            print('Failed to save screenshot');
          }
        }
      } else {
        if (kDebugMode) {
          print('Storage permission denied');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Wrapping the widget with RepaintBoundary with a key is
          // the key to capture the widget as an image
          RepaintBoundary(
            key: _globalKey,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.amber,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('Hello World!')),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _capturePng,
            child: const Text('Capture Widget'),
          ),
        ],
      ),
    );
  }
}
