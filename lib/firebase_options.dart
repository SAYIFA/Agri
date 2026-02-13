import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with the AgriShare Firebase app.
///
/// Generated via FlutterFire CLI for project: agrishare-app
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBrPj9NAp0EnTnl8Wf1TN34_LuMAKg5X_Y',
    appId: '1:463176542488:web:6518510bc87e20ddd9566d',
    messagingSenderId: '463176542488',
    projectId: 'agrishare-app',
    authDomain: 'agrishare-app.firebaseapp.com',
    storageBucket: 'agrishare-app.firebasestorage.app',
    measurementId: 'G-X1L6V6BZLN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBXZpkS7HqAgE40Bv8GThBuR1NBJOLFWVI',
    appId: '1:463176542488:android:6e764e59ddbc9dc6d9566d',
    messagingSenderId: '463176542488',
    projectId: 'agrishare-app',
    storageBucket: 'agrishare-app.firebasestorage.app',
  );

  // iOS is not configured yet. Run: flutterfire configure --platforms=ios
  // to generate the iOS config when needed.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: 'PLACEHOLDER',
    messagingSenderId: '463176542488',
    projectId: 'agrishare-app',
    storageBucket: 'agrishare-app.firebasestorage.app',
    iosBundleId: 'com.agrishare.agrishare',
  );
}
