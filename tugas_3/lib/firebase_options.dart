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
    apiKey: 'AIzaSyCVqOSsrEonhf42JxbabeZQQCbXj2jqBx8',
    appId: '1:918899889841:web:6488402b9b805e88fdb490',
    messagingSenderId: '918899889841',
    projectId: 'auth-notif-tugas-3',
    authDomain: 'auth-notif-tugas-3.firebaseapp.com',
    storageBucket: 'auth-notif-tugas-3.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAk3D3PM7imspD6-zEqbIBIoXF1DjxbKRM',
    appId: '1:918899889841:android:c8fe52ec3c13057ffdb490',
    messagingSenderId: '918899889841',
    projectId: 'auth-notif-tugas-3',
    storageBucket: 'auth-notif-tugas-3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCP8jnCcfu7gk1JQ1f826GgUodZGGzYUQQ',
    appId: '1:918899889841:ios:0f9c34a20386d362fdb490',
    messagingSenderId: '918899889841',
    projectId: 'auth-notif-tugas-3',
    storageBucket: 'auth-notif-tugas-3.firebasestorage.app',
    iosBundleId: 'com.example.tugas3',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCP8jnCcfu7gk1JQ1f826GgUodZGGzYUQQ',
    appId: '1:918899889841:ios:0f9c34a20386d362fdb490',
    messagingSenderId: '918899889841',
    projectId: 'auth-notif-tugas-3',
    storageBucket: 'auth-notif-tugas-3.firebasestorage.app',
    iosBundleId: 'com.example.tugas3',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCVqOSsrEonhf42JxbabeZQQCbXj2jqBx8',
    appId: '1:918899889841:web:bdaa49e95d4da285fdb490',
    messagingSenderId: '918899889841',
    projectId: 'auth-notif-tugas-3',
    authDomain: 'auth-notif-tugas-3.firebaseapp.com',
    storageBucket: 'auth-notif-tugas-3.firebasestorage.app',
  );

}