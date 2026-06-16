import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class AppBootstrapScreen extends StatelessWidget {
  const AppBootstrapScreen({
    super.key,
    this.ready = false,
    this.error,
  });

  final bool ready;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Firebase の初期化に失敗しました。\n$error\n\nREADME の設定手順を確認してください。',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (!ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final authService = context.read<AuthService>();
    return StreamBuilder(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const LoginScreen();
        }

        return const HomeScreen();
      },
    );
  }
}
