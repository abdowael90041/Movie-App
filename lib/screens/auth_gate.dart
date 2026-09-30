import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_view_model.dart';
import 'auth/login_screen.dart';
import 'main/app_shell.dart';
import 'splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    if (!auth.initialized) return const SplashScreen();
    if (auth.isLoggedIn) return const AppShell();
    return const LoginScreen();
  }
}
