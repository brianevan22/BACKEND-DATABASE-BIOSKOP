import 'package:flutter/material.dart';
import 'film_list_page.dart';
import '../theme/app_theme.dart';
import '../api_service.dart';
import 'login_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loggingOut = false;

  Future<void> _confirmAndLogout() async {
    if (_loggingOut) return;

    // Pastikan ada Material ancestor (sudah, karena kita pakai MaterialApp)
    final bool sure = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;

    if (!sure) return;

    setState(() => _loggingOut = true);
    final api = ApiService();
    try {
      await api
          .logout(); // aman walau endpoint /auth/logout belum ada (ditry/catch di ApiService)
    } catch (_) {
      // kita abaikan error agar UX mulus
    }

    if (!mounted) return;

    // (Opsional) beri feedback singkat sebelum pindah halaman
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil logout')),
    );

    // Pindah ke Login dan hapus seluruh riwayat
    // Gunakan microtask agar SnackBar sempat muncul sekejap (tidak wajib)
    Future.microtask(() {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    });

    // Kunci tombol sementara
    setState(() => _loggingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppTheme.buildGradientAppBar(
        context,
        'LotusCinema • Home',
        actions: [
          IconButton(
            icon: _loggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _loggingOut ? null : _confirmAndLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _HomeTile(
              icon: Icons.movie_outlined,
              title: 'Daftar Film',
              subtitle: 'Lihat film dan pesan tiket',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FilmListPage()),
              ),
            ),
            const SizedBox(height: 16),
            _HomeTile(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              subtitle: 'Informasi Lotus Cinema dan pengembangnya',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _HomeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: cs.primary.withOpacity(.12),
                child: Icon(icon, color: cs.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
