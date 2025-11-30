import 'package:flutter/material.dart';
import '../api_service.dart';
import '../theme/app_theme.dart';
import 'jadwal_form_page.dart';
import 'seat_selection_page.dart';

class JadwalListPage extends StatefulWidget {
  final int filmId;
  final String filmTitle;
  const JadwalListPage(
      {super.key, required this.filmId, required this.filmTitle});

  @override
  State<JadwalListPage> createState() => _JadwalListPageState();
}

class _JadwalListPageState extends State<JadwalListPage> {
  final api = ApiService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rows = [];
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _load();
  }

  Future<void> _loadRole() async {
    final role = await api.getStoredRole();
    if (!mounted) return;
    setState(() => _isAdmin = role == 'admin');
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await api.jadwalList(filmId: widget.filmId);
      setState(() => _rows = list);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _studioName(Map<String, dynamic> m) => (m['nama_studio'] ??
          m['studio_nama'] ??
          m['studio'] ??
          'Studio ${m['studio_id'] ?? '-'}')
      .toString();

  String _timeHHmm(String t) {
    if (t.isEmpty) return t;
    final p = t.split(':');
    return p.length >= 2 ? '${p[0]}:${p[1]}' : t;
  }

  Future<void> _create() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            JadwalFormPage(filmId: widget.filmId, filmTitle: widget.filmTitle),
      ),
    );
    if (ok == true) _load();
  }

  Future<void> _edit(Map<String, dynamic> row) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => JadwalFormPage(
          filmId: widget.filmId,
          filmTitle: widget.filmTitle,
          initial: row,
          jadwalId: (row['jadwal_id'] is num)
              ? (row['jadwal_id'] as num).toInt()
              : int.tryParse('${row['jadwal_id']}'),
        ),
      ),
    );
    if (ok == true) _load();
  }

  Future<void> _delete(int id) async {
    final sure = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Jadwal'),
            content: const Text('Yakin ingin menghapus jadwal ini?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Hapus')),
            ],
          ),
        ) ??
        false;
    if (!sure) return;
    try {
      await api.jadwalDelete(id);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Jadwal terhapus')));
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
      }
    }
  }

  void _openSeat(Map<String, dynamic> row) {
    final jadwalId = (row['jadwal_id'] is num)
        ? (row['jadwal_id'] as num).toInt()
        : int.tryParse('${row['jadwal_id']}') ?? 0;
    final studioId = (row['studio_id'] is num)
        ? (row['studio_id'] as num).toInt()
        : int.tryParse('${row['studio_id']}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeatSelectionPage(
          jadwalId: jadwalId,
          filmTitle: widget.filmTitle,
          studioId: studioId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppTheme.buildGradientAppBar(
        context,
        'Jadwal • ${widget.filmTitle}',
        actions: _isAdmin ? [] : null,
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Gagal memuat: $_error'))
              : (_rows.isEmpty
                  ? const Center(
                      child: Text('Belum ada jadwal. Tekan tombol “Tambah”.'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: _buildScheduleTable(context),
                            ),
                          ),
                        ],
                      ),
                    )),
    );
  }

  Widget _buildScheduleTable(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor.withOpacity(.6);
    final headerStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurface,
    );
    final bodyStyle = theme.textTheme.bodyMedium;

    final rows = <TableRow>[
      TableRow(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(.35),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Jadwal', style: headerStyle),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Tanggal', style: headerStyle),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Jam', style: headerStyle),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Studio', style: headerStyle),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child:
                Text('Tiket', style: headerStyle, textAlign: TextAlign.center),
          ),
        ],
      ),
    ];

    for (var i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      final jadwalId = (row['jadwal_id'] is num)
          ? (row['jadwal_id'] as num).toInt()
          : int.tryParse('${row['jadwal_id']}') ?? 0;
      final tanggal = (row['tanggal'] ?? '').toString();
      final jamMulai = _timeHHmm((row['jam_mulai'] ?? '').toString());
      final jamSelesai = _timeHHmm((row['jam_selesai'] ?? '').toString());
      final studio = _studioName(row);

      final actionWidgets = <Widget>[
        TextButton(
          onPressed: () => _openSeat(row),
          child: const Text('Lihat Kursi'),
        ),
      ];
      if (_isAdmin) {
        actionWidgets.addAll([
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
            onPressed: () => _edit(row),
          ),
          IconButton(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(jadwalId),
          ),
        ]);
      }

      rows.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jadwal ${i + 1}', style: bodyStyle),
                  if (_isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.edit),
                            onPressed: () => _edit(row),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            tooltip: 'Hapus',
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(jadwalId),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(tanggal, style: bodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('$jamMulai – $jamSelesai', style: bodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(studio, style: bodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: FilledButton(
                  onPressed: () => _openSeat(row),
                  child: const Text('Pesan Tiket'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Table(
      border: TableBorder.all(
        color: borderColor,
        width: 1,
        borderRadius: BorderRadius.circular(18),
      ),
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(1.1),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
        4: IntrinsicColumnWidth(),
      },
      children: rows,
    );
  }
}
