import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart';

void main() => runApp(MaterialApp(
      home: MaterialApp(
        home: MyHomePage(),
      ),
    ));

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Clean up temporary share files on app start.
    // By default, these files are deleted when the share window is closed,
    // but if the app was closed or crashed before that, some files may remain.
    // It's recommended to periodically clean up temp files for common share extensions.
    Share.deleteTempShareFilesByExtension('.png');
    Share.deleteTempShareFilesByExtension('.jpg');
    Share.deleteTempShareFilesByExtension('.csv');
    Share.deleteTempShareFilesByExtension('.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Share Example'),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: <Widget>[
                MaterialButton(
                  child: Text('Share text'),
                  onPressed: () async => await _shareText(),
                ),
                MaterialButton(
                  child: Text('Share image'),
                  onPressed: () async => await _shareImage(),
                ),
                MaterialButton(
                  child: Text('Share images'),
                  onPressed: () async => await _shareImages(),
                ),
                MaterialButton(
                  child: Text('Share CSV'),
                  onPressed: () async => await _shareCSV(),
                ),
                MaterialButton(
                  child: Text('Share mixed'),
                  onPressed: () async => await _shareMixed(),
                ),
                MaterialButton(
                  child: Text('Share image from url'),
                  onPressed: () async => await _shareImageFromUrl(),
                ),
                MaterialButton(
                  child: Text('Share sound'),
                  onPressed: () async => await _shareSound(),
                ),
              ],
            )));
  }

  Future<void> _shareText() async {
    try {
      Share.text('my text title',
          'This is my text to share with other applications.', 'text/plain');
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareImage() async {
    try {
      final ByteData bytes = await rootBundle.load('assets/image1.png');
      await Share.fileFromMemory(
          'esys image', 'esys.png', bytes.buffer.asUint8List(), 'image/png',
          text: 'My optional text.');
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareImages() async {
    try {
      final ByteData bytes1 = await rootBundle.load('assets/image1.png');
      final ByteData bytes2 = await rootBundle.load('assets/image2.png');

      await Share.filesFromMemory(
        'esys images',
        {
          'esys.png': bytes1.buffer.asUint8List(),
          'bluedan.png': bytes2.buffer.asUint8List(),
        },
        {'image/png'},
      );
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareCSV() async {
    try {
      final ByteData bytes = await rootBundle.load('assets/addresses.csv');
      await Share.fileFromMemory(
          'addresses', 'addresses.csv', bytes.buffer.asUint8List(), 'text/csv');
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareMixed() async {
    try {
      final ByteData bytes1 = await rootBundle.load('assets/image1.png');
      final ByteData bytes2 = await rootBundle.load('assets/image2.png');
      final ByteData bytes3 = await rootBundle.load('assets/addresses.csv');

      await Share.filesFromMemory(
          'esys images',
          {
            'esys.png': bytes1.buffer.asUint8List(),
            'bluedan.png': bytes2.buffer.asUint8List(),
            'addresses.csv': bytes3.buffer.asUint8List(),
          },
          {'*/*'},
          text: 'My optional text.');
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareImageFromUrl() async {
    try {
      var request = await HttpClient().getUrl(Uri.parse(
          'https://shop.esys.eu/media/image/6f/8f/af/amlog_transport-berwachung.jpg'));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      await Share.fileFromMemory('ESYS AMLOG', 'amlog.jpg', bytes, 'image/jpg');
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareSound() async {
    try {
      final ByteData bytes = await rootBundle.load('assets/cat.mp3');
      await Share.fileFromMemory(
          'Sound', 'cat.mp3', bytes.buffer.asUint8List(), 'audio/*');
    } catch (e) {
      print('error: $e');
    }
  }
}
