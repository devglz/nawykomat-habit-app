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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBmfQjipbHP9K15gXHeN7RcFd6lkZCGpp0',
    appId: '1:215452038327:web:a0de79bc5302e350bb4932',
    messagingSenderId: '215452038327',
    projectId: 'habbit-app-86883',
    authDomain: 'habbit-app-86883.firebaseapp.com',
    storageBucket: 'habbit-app-86883.firebasestorage.app',
    measurementId: 'G-BFTQ37H71B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdFIi20oZlCGZVsWtw0SY8WwbI4mlouGA',
    appId: '1:215452038327:android:c2ba5bea17f21b96bb4932',
    messagingSenderId: '215452038327',
    projectId: 'habbit-app-86883',
    storageBucket: 'habbit-app-86883.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBXDI514ozHeRFMHc1a_oLQwYUXHjMcWT0',
    appId: '1:215452038327:ios:468565bd640ce8f4bb4932',
    messagingSenderId: '215452038327',
    projectId: 'habbit-app-86883',
    storageBucket: 'habbit-app-86883.firebasestorage.app',
    iosBundleId: 'com.example.Nawykomat',
  );
}
