// Centralized Firebase configuration for all platforms.
// Generated manually (normally created by FlutterFire CLI).

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
				throw UnsupportedError(
						'DefaultFirebaseOptions have not been configured for iOS.');
			case TargetPlatform.macOS:
				throw UnsupportedError(
						'DefaultFirebaseOptions have not been configured for macOS.');
			case TargetPlatform.windows:
				throw UnsupportedError(
						'DefaultFirebaseOptions have not been configured for Windows.');
			case TargetPlatform.linux:
				throw UnsupportedError(
						'DefaultFirebaseOptions have not been configured for Linux.');
			default:
				throw UnsupportedError(
					'DefaultFirebaseOptions are not supported for this platform.',
				);
		}
	}

	// Web configuration
	static const FirebaseOptions web = FirebaseOptions(
		apiKey: 'AIzaSyAfAsj5fQ6Z9wULH7KEvk8jwbZX3o6dKdU',
		appId: '1:882074817980:web:84b5679467932ec3cbc7b9',
		messagingSenderId: '882074817980',
		projectId: 'fixora-291df',
		authDomain: 'fixora-291df.firebaseapp.com',
		storageBucket: 'fixora-291df.firebasestorage.app',
	);

	// Android configuration (from google-services.json)
	static const FirebaseOptions android = FirebaseOptions(
		apiKey: 'AIzaSyAfAsj5fQ6Z9wULH7KEvk8jwbZX3o6dKdU',
		appId: '1:882074817980:android:84b5679467932ec3cbc7b9',
		messagingSenderId: '882074817980',
		projectId: 'fixora-291df',
		storageBucket: 'fixora-291df.firebasestorage.app',
	);
}

