// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCBIUYn8DnOLlbaPb874G2w4tosvXyXKQo',
    appId: '1:693423727408:web:ce77e48e024d3359041ef5',
    messagingSenderId: '693423727408',
    projectId: 'rxvault-22325',
    authDomain: 'rxvault-22325.firebaseapp.com',
    storageBucket: 'rxvault-22325.appspot.com',
    measurementId: 'G-MSDNDTTWBR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9Qa4zhbEmWA7q9HWg6FB85yS5pDiKzOo',
    appId: '1:693423727408:android:a31278ad4dc268ff041ef5',
    messagingSenderId: '693423727408',
    projectId: 'rxvault-22325',
    storageBucket: 'rxvault-22325.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCsPkS2c_JednGfys43NF3KIq0VHLED1Y4',
    appId: '1:693423727408:ios:9f50bf4e41590546041ef5',
    messagingSenderId: '693423727408',
    projectId: 'rxvault-22325',
    storageBucket: 'rxvault-22325.appspot.com',
    iosBundleId: 'com.ensivo.rxvault',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCsPkS2c_JednGfys43NF3KIq0VHLED1Y4',
    appId: '1:693423727408:ios:9f50bf4e41590546041ef5',
    messagingSenderId: '693423727408',
    projectId: 'rxvault-22325',
    storageBucket: 'rxvault-22325.appspot.com',
    iosBundleId: 'com.ensivo.rxvault',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCBIUYn8DnOLlbaPb874G2w4tosvXyXKQo',
    appId: '1:693423727408:web:02dadd10d6747944041ef5',
    messagingSenderId: '693423727408',
    projectId: 'rxvault-22325',
    authDomain: 'rxvault-22325.firebaseapp.com',
    storageBucket: 'rxvault-22325.appspot.com',
    measurementId: 'G-V0JWQ38G5Z',
  );
}
