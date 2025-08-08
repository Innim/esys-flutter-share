# esys_flutter_share_plus

It's fork of [esys_flutter_share](https://github.com/esysberlin/esys-flutter-share).

A [Flutter](https://flutter.io) plugin for sharing files & text with other applications.

## IMPORTANT Note for iOS
If you are starting a new fresh app, you need to create the Flutter App with `flutter create -i swift` (see [flutter/flutter#13422 (comment)](https://github.com/flutter/flutter/issues/13422#issuecomment-392133780)), otherwise, you will get this message:
```
=== BUILD TARGET flutter_inappbrowser OF PROJECT Pods WITH CONFIGURATION Debug ===
The "Swift Language Version" (SWIFT_VERSION) build setting must be set to a supported value for targets which use Swift. Supported values are: 3.0, 4.0, 4.2. This setting can be set in the build settings editor.
```

If you still have this problem, try to edit iOS `Podfile` like this (see [#15](https://github.com/pichillilorenzo/flutter_inappbrowser/issues/15)):
```
target 'Runner' do
  use_frameworks!  # required by simple_permission
  ...
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'  # required by simple_permission
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
```

Instead, if you have already a non-swift project, you can check this issue to solve the problem: [Friction adding swift plugin to objective-c project](https://github.com/flutter/flutter/issues/16049).

## Usage

Import:

```dart
import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart';
```

Initialize the plugin (required):

```dart
// Call this method at app startup or before starting to work with sharing
await Share.init();
```

Share text:

```dart
Share.text('my text title', 'This is my text to share with other applications.', 'text/plain');
```

Share File from Storage (Recommended):
**Note:** This method is recommended for sharing files, especially large files, to avoid potential memory issues.

```dart
await EsysFlutterShare.fileFromStorage(
  'Share File',
  'example.pdf',
  '/path/to/your/example.pdf',
  'application/pdf',
  text: 'Check out this file!',
);
```

Share File from Memory (Use with Caution):
**Warning:** Use this method only for small files. For large files, use fileFromStorage to avoid potential out-of-memory errors.

```dart
final ByteData bytes = await rootBundle.load('assets/image1.png');
await Share.fileFromMemory('esys image', 'esys.png', bytes.buffer.asUint8List(), 'image/png', text: 'My optional text.');
```

Share Multiple Files from Storage (Recommended):

```dart
await EsysFlutterShare.filesFromStorage(
  'Share Files',
  {
    'image1.png': '/path/to/your/image1.png',
    'document.pdf': '/path/to/your/document.pdf',
  },
  {'image/png', 'application/pdf'},
  text: 'Here are some files!',
);
```

Share Multiple Files from Memory (Use with Caution):

```dart
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
    '*/*',
    text: 'My optional text.');
```

Share file from url:

```dart
var request = await HttpClient().getUrl(Uri.parse('https://shop.esys.eu/media/image/6f/8f/af/amlog_transport-berwachung.jpg'));
var response = await request.close();
Uint8List bytes = await consolidateHttpClientResponseBytes(response);
await Share.fileFromMemory('ESYS AMLOG', 'amlog.jpg', bytes, 'image/jpg');
```

Check out the example app in the Repository for further information.


