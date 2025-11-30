import 'package:flutter/material.dart';
import '../api_service.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _email = TextEditingController();
  final _noHp = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  final api = ApiService();

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      final name = _name.text.trim();
      final user = _username.text.trim();
      final pass = _password.text.trim();
      final email = _email.text.trim();
      final noHp = _noHp.text.trim();

      if (name.isEmpty ||
          user.isEmpty ||
          pass.isEmpty ||
          email.isEmpty ||
          noHp.isEmpty) {
        throw Exception(
            'Nama, username, password, email, dan No. HP wajib diisi');
      }
      // simple email format check
      final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailPattern.hasMatch(email)) {
        throw Exception('Format email tidak valid');
      }

      final res = await api.register(user, pass,
          name: name,
          email: email.isEmpty ? null : email,
          noHp: noHp.isEmpty ? null : noHp);
      if (!mounted) return;
      final msg = (res['message'] ?? 'Registrasi berhasil').toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$msg. Silakan login terlebih dahulu.')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Pendaftaran gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    _email.dispose();
    _noHp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 60, 18, 30),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Daftar Akun',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _username,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noHp,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'No. HP'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _password,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    onSubmitted: (_) => _register(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(cs.primary)),
                    onPressed: _loading ? null : _register,
                    child: Text(_loading ? 'Mendaftar...' : 'Daftar'),
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
