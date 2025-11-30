import 'package:flutter/material.dart';
import '../api_service.dart';
import 'home_page.dart';
import 'registration_page.dart';
import '../theme/app_theme.dart';
import 'admin/admin_home_page.dart';
import 'customer/customer_home_page.dart';
import '../theme/bubble_container.dart' as bc;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  final api = ApiService();

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final user = _username.text.trim();
      final pass = _password.text.trim();
      if (user.isEmpty || pass.isEmpty)
        throw Exception('Username/password wajib diisi');

      final result = await api.login(user, pass);
      final role = (result['role'] ?? 'customer').toString();
      if (!mounted) return;
      final target =
          role == 'admin' ? const AdminHomePage() : const CustomerHomePage();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => target));
    } on ApiException catch (e) {
      final msg = (e.status == 401 || e.status == 404)
          ? 'Username atau password salah'
          : e.message;
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login gagal: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -40,
            child: CircleAvatar(
                radius: 110, backgroundColor: cs.primary.withOpacity(.10)),
          ),
          Positioned(
            bottom: -50,
            right: -30,
            child: CircleAvatar(
                radius: 90,
                backgroundColor: cs.primaryContainer.withOpacity(.18)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          cs.primary.withOpacity(.20),
                          cs.primary.withOpacity(.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(26),
                    child: Column(
                      children: [
                        // Header welcome
                        Column(
                          children: [
                            // small logo circle
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
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.movie,
                                            color: Colors.white,
                                            size: 48),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Pusatkan tulisan selamat datang
                            Text(
                              'Selamat datang di Lotus Cinema',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: cs.primary),
                            ),
                            const SizedBox(height: 6),
                            Text('Silahkan login dahulu.',
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 199, 198, 198))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      child: Column(
                        children: [
                          TextField(
                            controller: _username,
                            decoration: const InputDecoration(
                              hintText: 'Username',
                              prefixIcon: Icon(Icons.person),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _password,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            obscureText: _obscurePassword,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _loading ? null : _login,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(_loading ? 'Masuk...' : 'Masuk'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  // footer prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Tidak punya akun? ',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 160, 160, 160))),
                      TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegistrationPage())),
                        child: const Text('Daftar dulu.'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
