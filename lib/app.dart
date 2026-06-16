import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/app_bootstrap_screen.dart';
import 'theme/app_theme.dart';

class RecBandApp extends StatelessWidget {
  const RecBandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecBand',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: FutureBuilder<FirebaseApp>(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppBootstrapScreen();
          }

          if (snapshot.hasError) {
            return AppBootstrapScreen(error: snapshot.error.toString());
          }

          return const AppBootstrapScreen(ready: true);
        },
      ),
    );
  }
}
