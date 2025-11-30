import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'admin/admin_home_page.dart';
import 'customer/customer_home_page.dart';
import '../theme/app_theme.dart';
import '../api_service.dart';
import '../theme/bubble_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // <-- tambahkan const constructor

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _checkAuth);
  }

  Future<void> _checkAuth() async {
    final api = ApiService();
    final token = await api.getStoredToken();

    if (!mounted) return;
    if (token != null) {
      api.setToken(token); // set untuk penggunaan selanjutnya
      final role = await api.getStoredRole();
      if (role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminHomePage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CustomerHomePage()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo bulat dengan shadow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 80,
                backgroundColor: cs.primary,
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png', // ganti dengan path logo project Anda
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.movie,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            BubbleContainer(
              gradient: true,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              child: const Text(
                'Lotus Cinema',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 26),
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
