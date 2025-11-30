import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class CheckoutSuccessPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const CheckoutSuccessPage({super.key, required this.data});

  String _formatRp(dynamic v) {
    final n = (v is num) ? v.toInt() : int.tryParse('${v ?? 0}') ?? 0;
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      b.write(s[i]);
      final left = s.length - i - 1;
      if (left > 0 && left % 3 == 0) b.write('.');
    }
    return b.toString();
  }

  /// Ambil label kursi dari berbagai bentuk payload dengan prioritas:
  /// 1) `kursi_labels` (string sudah jadi)
  /// 2) `kursi` (list of map) -> pakai `nomor_kursi`
  /// 3) fallback `kursi_terbeli` (id), jika tak ada nama sama sekali
  String _seatLabels(Map<String, dynamic> d) {
    final direct = d['kursi_labels']?.toString();
    if (direct != null && direct.trim().isNotEmpty) return direct;

    final k = d['kursi'];
    if (k is List && k.isNotEmpty) {
      final labels = k
          .map((e) {
            if (e is Map) {
              final m = Map<String, dynamic>.from(e);
              return (m['nomor_kursi'] ?? m['label'] ?? m['kursi']).toString();
            }
            return e.toString();
          })
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (labels.isNotEmpty) return labels.join(', ');
    }

    final ids = d['kursi_terbeli'];
    if (ids is List) return ids.join(', ');
    return '-';
  }

  List<String> _seatList(Map<String, dynamic> d) {
    final chips = <String>[];
    final kursi = d['kursi'];
    if (kursi is List) {
      for (final item in kursi) {
        if (item is Map && item.isNotEmpty) {
          final label = (item['nomor_kursi'] ?? item['label'] ?? item['kursi'])
              ?.toString();
          if (label != null && label.trim().isNotEmpty) chips.add(label.trim());
        } else if (item != null) {
          chips.add(item.toString());
        }
      }
    }
    if (chips.isEmpty) {
      final labels = (d['kursi_labels'] ?? '').toString();
      if (labels.trim().isNotEmpty) {
        chips.addAll(
            labels.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
      }
    }
    if (chips.isEmpty) {
      final ids = d['kursi_terbeli'];
      if (ids is List && ids.isNotEmpty) {
        chips.addAll(ids.map((e) => 'S$e').cast<String>());
      }
    }
    return chips;
  }

  Widget _infoRow(String label, String value, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _seatChips(List<String> seats, ColorScheme cs) {
    if (seats.isEmpty) {
      return Text(
        '-',
        style: TextStyle(color: cs.onSurfaceVariant),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: seats
          .map(
            (seat) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.primary.withOpacity(.4)),
              ),
              child: Text(
                seat,
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  List<Map<String, dynamic>> _ticketItems() {
    final seats = _seatList(data);
    final raw = (data['kursi'] as List?)
            ?.map((e) => e is Map ? Map<String, dynamic>.from(e) : null)
            .whereType<Map<String, dynamic>>()
            .toList() ??
        [];
    if (raw.length >= seats.length) {
      return raw.map((m) {
        final label =
            (m['nomor_kursi'] ?? m['label'] ?? m['kursi'] ?? '').toString();
        final ticketId = m['tiket_id'] ?? m['ticket_id'] ?? m['id'];
        return {
          'seat': label.isEmpty ? 'Seat' : label,
          'price': m['harga'],
          'tiketId': ticketId,
        };
      }).toList();
    }
    return seats
        .map((label) => {'seat': label, 'price': null, 'tiketId': null})
        .toList();
  }

  String _displayDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      final dt = DateTime.parse(value);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }

  String _onlyDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      final dt = DateTime.parse(value);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return value;
    }
  }

  String get _projectName =>
      (data['project_name'] ?? 'Lotus Cinema').toString();
  String get _filmTitle =>
      (data['film_title'] ?? data['film'] ?? '-').toString();
  String get _studioLabel => (data['studio_name'] ??
          data['studio'] ??
          'Studio ${data['studio_id'] ?? '-'}')
      .toString();
  String get _scheduleDateLabel =>
      _onlyDate(data['jadwal_tanggal']?.toString());
  String get _scheduleTimeLabel {
    final parts = [
      data['jadwal_mulai']?.toString(),
      data['jadwal_selesai']?.toString(),
    ].where((e) => e != null && e!.isNotEmpty).map((e) => e!).toList();
    return parts.join(' - ');
  }

  String get _purchaseDateLabel =>
      _displayDate(data['purchase_time']?.toString());

  Widget _ticketCard(Map<String, dynamic> ticket, int index, ColorScheme cs) {
    final seat = (ticket['seat'] ?? '-').toString();
    final price = ticket['price'];
    final ticketId = ticket['tiketId'];
    final ticketIdLabel =
        (ticketId == null || ticketId.toString().trim().isEmpty)
            ? '-'
            : ticketId.toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(.35)),
        gradient: LinearGradient(
          colors: [cs.surface, cs.surfaceVariant.withOpacity(.35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.weekend, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Tiket ${index + 1} • Kursi $seat',
                style:
                    TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow('ID Tiket', '#$ticketIdLabel', cs),
          _infoRow('Film', _filmTitle, cs),
          _infoRow('Studio', _studioLabel, cs),
          _infoRow('Kursi', seat, cs),
          _infoRow('Jadwal', _scheduleDateLabel, cs),
          if (_scheduleTimeLabel.isNotEmpty)
            _infoRow('Jam', _scheduleTimeLabel, cs),
          _infoRow('Tanggal Beli', _purchaseDateLabel, cs),
          if (price != null) _infoRow('Harga', 'Rp ${_formatRp(price)}', cs),
        ],
      ),
    );
  }

  Future<Uint8List> _buildTicketsPdf({PdfPageFormat? format}) async {
    final baseFont = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    final pdfDoc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
        italic: baseFont,
        boldItalic: boldFont,
      ),
    );
    final tickets = _ticketItems();
    final pdfFormat = format ?? PdfPageFormat.a4;
    final project = _projectName;
    final film = _filmTitle;
    final studio = _studioLabel;
    final scheduleDate = _scheduleDateLabel;
    final scheduleTime = _scheduleTimeLabel;
    final purchase = _purchaseDateLabel;

    for (var i = 0; i < tickets.length; i++) {
      final ticket = tickets[i];
      final seatLabel = (ticket['seat'] ?? '-').toString();
      final price = ticket['price'];
      final ticketId = ticket['tiketId'];
      final ticketIdLabel =
          (ticketId == null || ticketId.toString().trim().isEmpty)
              ? '-'
              : ticketId.toString();

      pdfDoc.addPage(
        pw.Page(
          pageFormat: pdfFormat,
          build: (_) => pw.Container(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.SizedBox(height: 12),
                pw.Text(project,
                    style: pw.TextStyle(
                        fontSize: 26, fontWeight: pw.FontWeight.bold)),
                pw.Text('ID Tiket              : #$ticketIdLabel'),
                pw.Text('Film                  : $film'),
                pw.Text('Studio                : $studio'),
                pw.Text('Kursi                 : $seatLabel'),
                pw.Text('Jadwal                : $scheduleDate'),
                if (scheduleTime.isNotEmpty)
                  pw.Text('Jam                 : $scheduleTime'),
                pw.Text('Tanggal Beli          : $purchase'),
                if (price != null)
                  pw.Text('Harga               : Rp ${_formatRp(price)}'),
                pw.SizedBox(height: 18),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 24),
                pw.Text('*harap datang 15 menit sebelum jadwal pemutaran.',
                    style: pw.TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ),
      );
    }

    return pdfDoc.save();
  }

  Future<Directory> _resolveDownloadDir() async {
    try {
      final dir = await getDownloadsDirectory();
      if (dir != null) return dir;
    } catch (_) {
      // ignore, fallback below
    }
    try {
      final dir = await getExternalStorageDirectory();
      if (dir != null) return dir;
    } catch (_) {
      // ignore
    }
    return await getTemporaryDirectory();
  }

  Future<void> _openPdfFallback(
      BuildContext context, Uint8List bytes, String filename) async {
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: filename);
      return;
    }
    try {
      final dir = await _resolveDownloadDir();
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file =
          await File('${dir.path}/$filename').writeAsBytes(bytes, flush: true);
      await OpenFilex.open(file.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF disimpan di ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka PDF: $e')),
        );
      }
    }
  }

  Future<void> _printTickets(BuildContext context) async {
    final tickets = _ticketItems();
    if (tickets.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada tiket untuk dicetak.')),
        );
      }
      return;
    }

    final filename = 'tiket_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final fallbackBytes = await _buildTicketsPdf();

    try {
      if (kIsWeb) {
        await Printing.layoutPdf(
          name: filename,
          onLayout: (format) async => fallbackBytes,
        );
        return;
      }
      await Printing.layoutPdf(
        name: filename,
        onLayout: (format) => _buildTicketsPdf(format: format),
      );
      return;
    } on MissingPluginException catch (e) {
      debugPrint('Printing plugin unavailable: $e');
    } catch (e) {
      debugPrint('Printing error: $e');
    }

    await _openPdfFallback(context, fallbackBytes, filename);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final cs = Theme.of(context).colorScheme;
    final trxId = data['transaksi_id'] ?? data['id'] ?? '-';
    final total = data['total_harga'] ?? 0;
    final seats = _seatList(data);
    final tickets = _ticketItems();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppTheme.buildGradientAppBar(context, 'Checkout'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 6,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  cs.primary.withOpacity(.12),
                  cs.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: primary.withOpacity(.15),
                  child: Icon(Icons.check_rounded, color: primary, size: 40),
                ),
                const SizedBox(height: 18),
                Text(
                  'Pembayaran Berhasil!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Terima kasih telah melakukan pemesanan. Silakan cetak tiket Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                Divider(color: cs.outlineVariant.withOpacity(.4)),
                _infoRow('Transaksi ID', '#$trxId', cs),
                _infoRow('Total Bayar', 'Rp ${_formatRp(total)}', cs),
                const SizedBox(height: 12),
                Text(
                  'Kursi',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _seatChips(seats, cs),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: tickets.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Tiket akan muncul di sini setelah transaksi berhasil.',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          )
                        : Column(
                            children: tickets
                                .asMap()
                                .entries
                                .map((entry) =>
                                    _ticketCard(entry.value, entry.key, cs))
                                .toList(),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed:
                      tickets.isEmpty ? null : () => _printTickets(context),
                  icon: const Icon(Icons.print),
                  label: const Text('Cetak Tiket'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('Kembali ke Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
