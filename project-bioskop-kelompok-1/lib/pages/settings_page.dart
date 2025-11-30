import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppTheme.buildGradientAppBar(context, 'Lotus Cinema'),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SizedBox(height: 32),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 48, color: cs.primary),
                const SizedBox(height: 16),
                Text(
                  'Tentang Aplikasi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aplikasi Lotus Cinema adalah sistem pemesanan tiket bioskop modern yang memudahkan Anda melihat jadwal film, memilih kursi, dan melakukan pembayaran secara online.\n\nDikembangkan oleh Tim Korlap PSDKU.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Text(
                  'Versi 1.0.0',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
