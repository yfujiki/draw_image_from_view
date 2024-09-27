import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

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
      final directory = (await getApplicationDocumentsDirectory()).path;
      File imgFile = File('$directory/screenshot.png');
      imgFile.writeAsBytes(pngBytes);

      if (kDebugMode) {
        print('Screenshot saved to $directory/screenshot.png');
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
