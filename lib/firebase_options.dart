import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
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

  // ── Android (from your google-services.json) ──────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCiylvSa7YBBhG1aAe9n3CyTufrhLneJBI',
    appId: '1:514426679434:android:e9661ded0274f3ffd27d73',
    messagingSenderId: '514426679434',
    projectId: 'storage-b4c83',
    storageBucket: 'storage-b4c83.firebasestorage.app',
  );

  // ── Web (fill in if you add a web app in Firebase Console) ────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCiylvSa7YBBhG1aAe9n3CyTufrhLneJBI',
    appId: 'YOUR_WEB_APP_ID',          // Add from Firebase Console → Web app
    messagingSenderId: '514426679434',
    projectId: 'storage-b4c83',
    authDomain: 'storage-b4c83.firebaseapp.com',
    storageBucket: 'storage-b4c83.firebasestorage.app',
  );

  // ── iOS (fill in if you add an iOS app in Firebase Console) ───
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCiylvSa7YBBhG1aAe9n3CyTufrhLneJBI',
    appId: 'YOUR_IOS_APP_ID',          // Add from Firebase Console → iOS app
    messagingSenderId: '514426679434',
    projectId: 'storage-b4c83',
    storageBucket: 'storage-b4c83.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.shopease',
  );
}