
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;



class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDmaZqwQFs1pCxGp-PDnElBaWgXk6N5Svc',
    appId: '1:211511751062:android:1060106b4b2695d1206db7',
    messagingSenderId: '211511751062',
    projectId: 'dbase2-81978',
    databaseURL: 'https://dbase2-81978-default-rtdb.firebaseio.com',
    storageBucket: 'dbase2-81978.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZ0GFqZhWo0NmhTwJVjA8YAymg5-TZmw4',
    appId: '1:211511751062:ios:8beaf741878b167d206db7',
    messagingSenderId: '211511751062',
    projectId: 'dbase2-81978',
    databaseURL: 'https://dbase2-81978-default-rtdb.firebaseio.com',
    storageBucket: 'dbase2-81978.firebasestorage.app',
    iosBundleId: 'com.example.lab8',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCMQB4su77eEZw4l30TaaGTpBE-i2-xW_k',
    appId: '1:211511751062:web:51a51decd9f09470206db7',
    messagingSenderId: '211511751062',
    projectId: 'dbase2-81978',
    authDomain: 'dbase2-81978.firebaseapp.com',
    databaseURL: 'https://dbase2-81978-default-rtdb.firebaseio.com',
    storageBucket: 'dbase2-81978.firebasestorage.app',
    measurementId: 'G-0MTL92CXYZ',
  );
}
