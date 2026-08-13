import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAKUpdwiZdpss982G6QvzL4AKFfnSaRloE',
    appId: '1:136497821478:web:a6f0d06bc3473b80eeb3e7',
    messagingSenderId: '136497821478',
    projectId: 'parosis-446b6',
    authDomain: 'parosis-446b6.firebaseapp.com',
    storageBucket: 'parosis-446b6.firebasestorage.app',
    measurementId: 'G-4G5W7NDWEE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSh_OiGRm24FoCFOCtPTjqALVCAXu4IJk',
    appId: '1:136497821478:android:b3096f0eafbdebaaeeb3e7',
    messagingSenderId: '136497821478',
    projectId: 'parosis-446b6',
    storageBucket: 'parosis-446b6.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAuKcO7HRKqE3_TZkFaTVDF2A0Vw_nrknE',
    appId: '1:136497821478:ios:7ab71d94e974ceb2eeb3e7',
    messagingSenderId: '136497821478',
    projectId: 'parosis-446b6',
    storageBucket: 'parosis-446b6.firebasestorage.app',
    androidClientId:
        '136497821478-gmv9abh4nlo2comnvrppiisv2509rbd4.apps.googleusercontent.com',
    iosClientId:
        '136497821478-p5nsthe5hjspjvc5cg3r56b9rok7cm56.apps.googleusercontent.com',
    iosBundleId: 'com.parosis.sulama',
  );
}
