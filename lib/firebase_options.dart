// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyAMfhb3S-7mILbwrV7O2zdN6BGb_FpyqY8',
    appId: '1:818606665197:web:32ffd8401040dcfd868be4',
    messagingSenderId: '818606665197',
    projectId: 'chatsxapp',
    authDomain: 'chatsxapp.firebaseapp.com',
    storageBucket: 'chatsxapp.appspot.com',
    measurementId: 'G-MYJVL2J0N5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDdAnkaJsqJFsViKcMobJs7SuJbgjqJy2M',
    appId: '1:818606665197:android:bbdddc65ccb6c901868be4',
    messagingSenderId: '818606665197',
    projectId: 'chatsxapp',
    storageBucket: 'chatsxapp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDx1WkMajXoWXy7Xobe6RVPvhYaOJdIMcQ',
    appId: '1:818606665197:ios:51b3f793e7dcbd40868be4',
    messagingSenderId: '818606665197',
    projectId: 'chatsxapp',
    storageBucket: 'chatsxapp.appspot.com',
    androidClientId: '818606665197-4sakojlecuobit5mmffgf11deq11mlvf.apps.googleusercontent.com',
    iosClientId: '818606665197-l4sqk07j3p293incqeh3vcpqampge6p1.apps.googleusercontent.com',
    iosBundleId: 'com.alamsyah.chatsx',
  );
}
