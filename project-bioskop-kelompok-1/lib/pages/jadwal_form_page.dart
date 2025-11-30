import 'package:flutter/material.dart';
import '../api_service.dart';
import '../theme/app_theme.dart';

class JadwalFormPage extends StatefulWidget {
  final int filmId;
  final String filmTitle;
  final Map<String, dynamic>? initial;
  final int? jadwalId;
  const JadwalFormPage({
    super.key,
    required this.filmId,
    required this.filmTitle,
    this.initial,
    this.jadwalId,
  });

  @override
  State<JadwalFormPage> createState() => _JadwalFormPageState();
}

class _JadwalFormPageState extends State<JadwalFormPage> {
  final api = ApiService();
  final _form = GlobalKey<FormState>();

  bool _loading = false;
  List<Map<String, dynamic>> _studios = [];

  int? _studioId;
  DateTime? _tanggal;
  TimeOfDay? _mulai;
  TimeOfDay? _selesai;

  // controller sederhana (readOnly) agar tidak kedip saat rebuild
  late final TextEditingController _tglCtl;
  late final TextEditingController _mulaiCtl;
  late final TextEditingController _selesaiCtl;

  @override
  void initState() {
    super.initState();
    _tglCtl = TextEditingController();
    _mulaiCtl = TextEditingController();
    _selesaiCtl = TextEditingController();
    _prefill();
    _loadStudios();
  }

  @override
  void dispose() {
    _tglCtl.dispose();
    _mulaiCtl.dispose();
    _selesaiCtl.dispose();
    super.dispose();
  }

  void _prefill() {
    final m = widget.initial;
    if (m == null) return;

    // studio
    final rawStudio = m['studio_id'] ?? m['id_studio'];
    _studioId =
        (rawStudio is num) ? rawStudio.toInt() : int.tryParse('$rawStudio');

    // tanggal
    final tgl = (m['tanggal'] ?? '').toString();
    if (tgl.isNotEmpty) {
      try {
        _tanggal = DateTime.parse(tgl);
      } catch (_) {}
      _tglCtl.text = _fmtDate(_tanggal);
    }

    // jam
    String toStr(v) => (v ?? '').toString();
    TimeOfDay? _parse(String s) {
      final p = s.split(':');
      if (p.length >= 2) {
        final h = int.tryParse(p[0]) ?? 0;
        final m = int.tryParse(p[1]) ?? 0;
        return TimeOfDay(hour: h, minute: m);
      }
      return null;
    }

    _mulai = _parse(toStr(m['jam_mulai']));
    _selesai = _parse(toStr(m['jam_selesai']));
    _mulaiCtl.text = _fmtTime(_mulai).replaceAll(':00', '');
    _selesaiCtl.text = _fmtTime(_selesai).replaceAll(':00', '');
  }

  Future<void> _loadStudios() async {
    try {
      final list = await api.studiosList();
      setState(() => _studios = list);
      // fallback default jika kosong
      if (_studios.isEmpty) {
        setState(() {
          _studios = const [
            {'id': 1, 'nama': 'Studio 1'},
            {'id': 2, 'nama': 'Studio 2'},
            {'id': 3, 'nama': 'Studio 3'},
          ];
        });
      }
      // auto pilih kalau belum ada
      _studioId ??=
          (_studios.isNotEmpty ? (_studios.first['id'] as int? ?? 1) : 1);
    } catch (e) {
      setState(() {
        _studios = const [
          {'id': 1, 'nama': 'Studio 1'},
          {'id': 2, 'nama': 'Studio 2'},
          {'id': 3, 'nama': 'Studio 3'},
        ];
        _studioId ??= 1;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat studio: $e')));
    }
  }

  String _fmtDate(DateTime? d) => d == null
      ? ''
      : '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(TimeOfDay? t) => t == null
      ? ''
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (d != null) {
      setState(() => _tanggal = d);
      _tglCtl.text = _fmtDate(_tanggal);
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final t = await showTimePicker(
      context: context,
      initialTime: (isStart ? _mulai : _selesai) ?? TimeOfDay.now(),
    );
    if (t != null) {
      setState(() {
        if (isStart) {
          _mulai = t;
          _mulaiCtl.text = _fmtTime(_mulai).replaceAll(':00', '');
        } else {
          _selesai = t;
          _selesaiCtl.text = _fmtTime(_selesai).replaceAll(':00', '');
        }
      });
    }
  }

  bool _timeOrderValid() {
    if (_mulai == null || _selesai == null) return true;
    final m = _mulai!;
    final s = _selesai!;
    final startMin = m.hour * 60 + m.minute;
    final endMin = s.hour * 60 + s.minute;
    return endMin > startMin;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_studioId == null ||
        _tanggal == null ||
        _mulai == null ||
        _selesai == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lengkapi semua field')));
      return;
    }
    if (!_timeOrderValid()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Jam selesai harus lebih besar dari jam mulai')));
      return;
    }

    setState(() => _loading = true);
    try {
      if (widget.jadwalId == null) {
        await api.jadwalCreate(
          filmId: widget.filmId,
          studioId: _studioId!,
          tanggal: _fmtDate(_tanggal),
          jamMulai: _fmtTime(_mulai),
          jamSelesai: _fmtTime(_selesai),
        );
      } else {
        await api.jadwalUpdate(
          widget.jadwalId!,
          filmId: widget.filmId,
          studioId: _studioId!,
          tanggal: _fmtDate(_tanggal),
          jamMulai: _fmtTime(_mulai),
          jamSelesai: _fmtTime(_selesai),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isEdit = widget.jadwalId != null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppTheme.buildGradientAppBar(
        context,
        '${isEdit ? "Edit" : "Tambah"} Jadwal • ${widget.filmTitle}',
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Studio
            DropdownButtonFormField<int>(
              value: _studioId,
              items: _studios.map((s) {
                final id = s['id'] as int;
                final nama =
                    (s['nama'] ?? s['nama_studio'] ?? 'Studio $id').toString();
                return DropdownMenuItem<int>(value: id, child: Text(nama));
              }).toList(),
              onChanged: (v) => setState(() => _studioId = v),
              decoration: const InputDecoration(
                  labelText: 'Studio', border: OutlineInputBorder()),
              validator: (v) => v == null ? 'Pilih studio' : null,
            ),
            const SizedBox(height: 12),

            // Tanggal
            TextFormField(
              readOnly: true,
              controller: _tglCtl,
              decoration: InputDecoration(
                labelText: 'Tanggal (YYYY-MM-DD)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
              validator: (_) => _tanggal == null ? 'Pilih tanggal' : null,
            ),
            const SizedBox(height: 12),

            // Jam Mulai
            TextFormField(
              readOnly: true,
              controller: _mulaiCtl,
              decoration: InputDecoration(
                labelText: 'Jam Mulai (HH:mm)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.schedule),
                  onPressed: () => _pickTime(true),
                ),
              ),
              validator: (_) => _mulai == null ? 'Pilih jam mulai' : null,
            ),
            const SizedBox(height: 12),

            // Jam Selesai
            TextFormField(
              readOnly: true,
              controller: _selesaiCtl,
              decoration: InputDecoration(
                labelText: 'Jam Selesai (HH:mm)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.schedule),
                  onPressed: () => _pickTime(false),
                ),
              ),
              validator: (_) => _selesai == null ? 'Pilih jam selesai' : null,
            ),
            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _loading ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(
                _loading
                    ? 'Menyimpan...'
                    : (isEdit ? 'Simpan Perubahan' : 'Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
