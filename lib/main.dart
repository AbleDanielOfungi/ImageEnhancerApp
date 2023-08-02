import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Enhancement App',
      home: ImageEnhancementScreen(),
    );
  }
}

class ImageEnhancementScreen extends StatefulWidget {
  @override
  _ImageEnhancementScreenState createState() => _ImageEnhancementScreenState();
}

class _ImageEnhancementScreenState extends State<ImageEnhancementScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  img.Image? originalImage;
  img.Image? enhancedImage;

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        originalImage = img.decodeImage(Uint8List.fromList(bytes));
        enhancedImage = enhanceImage(originalImage!);
      });
    }
  }

  img.Image enhanceImage(img.Image originalImage) {
    // Set the brightness factor for enhancement (increase brightness)
    final double brightnessFactor = 1.5;

    // Create a copy of the original image to store the enhanced result
    final img.Image enhancedImage = img.Image.from(originalImage);

    // Apply brightness enhancement to each pixel
    for (int y = 0; y < enhancedImage.height; y++) {
      for (int x = 0; x < enhancedImage.width; x++) {
        int pixel = enhancedImage.getPixel(x, y);

        int alpha = img.getAlpha(pixel);
        int red = img.getRed(pixel);
        int green = img.getGreen(pixel);
        int blue = img.getBlue(pixel);

        red = (red * brightnessFactor).round();
        green = (green * brightnessFactor).round();
        blue = (blue * brightnessFactor).round();

        // Ensure the pixel values stay within the valid range (0 to 255)
        red = red.clamp(0, 255);
        green = green.clamp(0, 255);
        blue = blue.clamp(0, 255);

        pixel = img.getColor(alpha, red, green, blue);
        enhancedImage.setPixel(x, y, pixel);
      }
    }

    return enhancedImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Enhancement'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (originalImage != null) ...[
              Image.memory(Uint8List.fromList(img.encodeJpg(originalImage!))),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    enhancedImage = enhanceImage(originalImage!);
                  });
                },
                child: Text('Enhance Image'),
              ),
            ],
            if (enhancedImage != null) ...[
              SizedBox(height: 20),
              Image.memory(Uint8List.fromList(img.encodeJpg(enhancedImage!))),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.photo),
      ),
    );
  }
}
