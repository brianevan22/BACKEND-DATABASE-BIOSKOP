import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/bubble_container.dart';
import '../film_list_page.dart';
import '../login_page.dart';
import '../settings_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final api = ApiService();
  bool _signingOut = false;

  Future<void> _confirmAndLogout() async {
    if (_signingOut) return;
    final sure = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Logout')),
            ],
          ),
        ) ??
        false;
    if (!sure) return;
    setState(() => _signingOut = true);
    try {
      await api.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Berhasil logout')));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Logout gagal')));
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppTheme.buildGradientAppBar(
        context,
        'Admin Dashboard',
        actions: [
          IconButton(
            onPressed: _signingOut ? null : _confirmAndLogout,
            icon: _signingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.movie_creation_outlined, color: primary),
              title: const Text('Kelola Film'),
              subtitle: const Text('Tambah, ubah, dan hapus film'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FilmListPage()),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.info_outline, color: primary),
              title: const Text('Tentang Aplikasi'),
              subtitle: const Text('Informasi Lotus Cinema dan pengembangnya'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
