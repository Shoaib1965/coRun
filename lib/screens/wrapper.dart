import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:co_run/services/auth_service.dart';
import 'package:co_run/screens/auth/login_screen.dart';
import 'package:co_run/screens/home/home_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // Check if user is logged in
    // This is a simplified check. Real app would use StreamBuilder.
    // For now, let's assume AuthService exposes a user stream or user object.
    
    return StreamBuilder(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? const LoginScreen() : const HomeScreen();
        } else {
          return const Scaffold(
            body: Center(child: CircularCircularProgressIndicator()),
          );
        }
      },
    );
  }
}
