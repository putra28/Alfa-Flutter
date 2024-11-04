// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'screens/homepage.dart';
import 'screens/loading_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Color(0xFFBB1724), // warna utama
          secondary: Color(0xFFE57373), // warna sekunder
          surface: Colors.white, // warna latar belakang umum
          background: Colors.white, // warna latar belakang
          error: Colors.red, // warna untuk elemen error
          onPrimary: Colors.white, // warna teks pada elemen dengan warna primary
          onSecondary: Colors.white, // warna teks pada elemen dengan warna secondary
          onSurface: Colors.black, // warna teks pada elemen surface
          onBackground: Colors.black, // warna teks pada elemen background
          onError: Colors.white, // warna teks pada elemen error
          brightness: Brightness.light, // atur ke Brightness.dark untuk tema gelap
        ),
        useMaterial3: false, // Menggunakan Material 2
      ),
      home: const SplashScreen(),
      routes: {
        '/loading': (context) => const LoadingScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) { // Pastikan widget masih terpasang
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen(); // Tampilkan LoadingScreen
  }
}
