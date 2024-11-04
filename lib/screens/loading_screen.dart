// lib/screens/loading_screen.dart
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Image.asset(
          'assets/images/logo_alfamart_white.png',
          width: 150, // Ubah ukuran logo sesuai kebutuhan
          height: 150,
        ),
      ),
    );
  }
}
