
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC1ia30viGkJgDSfNi178nBAUgyhPHbKJA',
    appId: '1:1023725809630:web:a7e0d43da26ab5ee1a374f',
    messagingSenderId: '1023725809630',
    projectId: 'el-karma-ph-11c4c',
    authDomain: 'el-karma-ph-11c4c.firebaseapp.com',
    storageBucket: 'el-karma-ph-11c4c.firebasestorage.app',
    measurementId: 'G-6YMLBDR5CP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCljf0nNzrw33lFos4CAMaKsJJUSa4Rff8',
    appId: '1:1023725809630:android:8d710bd953ed36561a374f',
    messagingSenderId: '1023725809630',
    projectId: 'el-karma-ph-11c4c',
    storageBucket: 'el-karma-ph-11c4c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDf2J1asm-HFg7iuOqNj31uW_AtAVnNjs',
    appId: '1:1023725809630:ios:e2a2d2c6ebdbefac1a374f',
    messagingSenderId: '1023725809630',
    projectId: 'el-karma-ph-11c4c',
    storageBucket: 'el-karma-ph-11c4c.firebasestorage.app',
    iosBundleId: 'com.example.elKarmaPh',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC1ia30viGkJgDSfNi178nBAUgyhPHbKJA',
    appId: '1:1023725809630:web:d814949147928d6f1a374f',
    messagingSenderId: '1023725809630',
    projectId: 'el-karma-ph-11c4c',
    authDomain: 'el-karma-ph-11c4c.firebaseapp.com',
    storageBucket: 'el-karma-ph-11c4c.firebasestorage.app',
    measurementId: 'G-H40WGCPVNJ',
  );
}
