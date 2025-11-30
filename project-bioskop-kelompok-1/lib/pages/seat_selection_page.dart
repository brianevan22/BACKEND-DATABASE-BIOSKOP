import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'checkout_success_page.dart';
import '../theme/app_theme.dart';

class SeatSelectionPage extends StatefulWidget {
  final int jadwalId;
  final String filmTitle;
  final int? studioId; // ✅ dipakai saat kursi kosong untuk generate virtual

  const SeatSelectionPage({
    super.key,
    required this.jadwalId,
    required this.filmTitle,
    this.studioId,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final api = ApiService();
  Map<String, dynamic>? _jadwal;

  String? _role; // tersimpan role user (admin/customer)

  bool _loading = true;
  String? _error;

  // data kursi dari API (atau virtual)
  List<Map<String, dynamic>> _seats = [];

  // lookup & pilihan
  final Set<int> _selected = {};
  final Map<int, Map<String, dynamic>> _byId = {}; // kursi_id -> row
  static const List<Map<String, dynamic>> _seatLayoutBlueprint = [
    {'row': 'A', 'left': 4, 'right': 4},
    {'row': 'B', 'left': 4, 'right': 4},
    {'row': 'C', 'left': 4, 'right': 4},
    {'row': 'D', 'left': 4, 'right': 4},
    {'row': 'E', 'center': 10},
  ];

  int get _denahSeatTotal => _seatLayoutBlueprint.fold<int>(
        0,
        (sum, cfg) =>
            sum +
            ((cfg['left'] as int?) ?? 0) +
            ((cfg['right'] as int?) ?? 0) +
            ((cfg['center'] as int?) ?? 0),
      );

  @override
  void initState() {
    super.initState();
    _loadRole();
    _load();
  }

  Future<void> _loadRole() async {
    try {
      final r = await api.getStoredRole();
      if (!mounted) return;
      setState(() => _role = r);
    } catch (_) {
      // ignore
    }
  }

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString().split('.').first) ??
        (double.tryParse('$v')?.round() ?? 0);
  }

  void _rebuildIndex(List<Map<String, dynamic>> rows) {
    _byId.clear();
    for (final m in rows) {
      final id = (m['kursi_id'] is num)
          ? (m['kursi_id'] as num).toInt()
          : int.tryParse('${m['kursi_id']}') ?? 0;
      if (id != 0) _byId[id] = m;
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _selected.clear();
    });
    try {
      final rows = await api.seatsAvailable(widget.jadwalId);
      final parsed =
          rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      if (parsed.isEmpty && widget.studioId != null) {
        // ✅ tidak ada kursi: tawarkan generate 15 kursi
        await _offerGenerateSeats();
      } else {
        _rebuildIndex(parsed);
        setState(() => _seats = parsed);
      }
      await _ensureJadwalInfo();
    } catch (e) {
      setState(() => _error = 'Gagal load kursi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _ensureJadwalInfo() async {
    if (_jadwal != null) return;
    try {
      final info = await api.jadwalShow(widget.jadwalId);
      if (!mounted) return;
      setState(() => _jadwal = info);
    } catch (_) {
      // abaikan jika gagal, fallback ditangani saat cetak
    }
  }

  // ==== Virtual Seat Generator (saat kursi kosong) ====
  String _studioLetter(int sid) {
    final base = 'A'.codeUnitAt(0);
    final idx = sid - 1;
    final code = base + (idx < 0 ? 0 : idx);
    return String.fromCharCode(code.clamp(base, 'Z'.codeUnitAt(0)));
  }

  int _defaultPrice(int sid) {
    const map = {1: 50000, 2: 100000, 3: 75000};
    return map[sid] ?? 50000;
  }

  Future<void> _offerGenerateSeats() async {
    final sid = widget.studioId!;
    final expectedLetter = _studioLetter(sid);
    String chosen = expectedLetter;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Generate Kursi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Belum ada kursi untuk jadwal ini.\n'
                  'Pilih baris kursi (A–C), lalu kami tampilkan 15 kursi.'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['A', 'B', 'C'].map((letter) {
                  final selected = chosen == letter;
                  return ChoiceChip(
                    label: Text(letter),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => chosen = letter);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                'Catatan: Studio ini default baris $expectedLetter. '
                'Saat disimpan, label kursi akan mengikuti studio.',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Lanjut')),
          ],
        );
      },
    );

    // Tetap pakai expectedLetter agar konsisten dengan backend
    final prefix = expectedLetter;
    final price = _defaultPrice(sid);
    final totalSeatVirtual = _denahSeatTotal;

    final virtual = <Map<String, dynamic>>[];
    int running = 0;
    for (final cfg in _seatLayoutBlueprint) {
      final row = cfg['row'] as String;
      final rowCount =
          (cfg['left'] ?? 0) + (cfg['right'] ?? 0) + (cfg['center'] ?? 0);
      for (var i = 1; i <= rowCount; i++) {
        running++;
        final label = '$row$i';
        final negativeId = -(sid * 1000 + running);
        virtual.add({
          'kursi_id': negativeId,
          'studio_id': sid,
          'nama_kursi': label,
          'status': 'tersedia',
          'harga': price,
        });
      }
    }

    _rebuildIndex(virtual);
    setState(() => _seats = virtual);
  }

  String _labelOf(Map<String, dynamic> s) {
    return (s['nama_kursi'] ??
            s['nomor_kursi'] ??
            s['label'] ??
            s['kursi_id'] ??
            '')
        .toString();
  }

  String _labelById(int id) {
    final m = _byId[id];
    if (m == null) return 'S$id';
    return _labelOf(m);
  }

  bool _isSold(Map<String, dynamic> s) {
    final st = (s['status'] ?? '').toString().toLowerCase();
    return st == 'terjual' || st == 'sold';
  }

  int _priceOfId(int kursiId) {
    final m = _byId[kursiId];
    return _asInt(m?['harga']);
  }

  int get _total {
    int sum = 0;
    for (final id in _selected) {
      sum += _priceOfId(id);
    }
    return sum;
  }

  String get _selectedLabels {
    if (_selected.isEmpty) return '-';
    return _selected.map(_labelById).join(', ');
  }

  Future<void> _checkout() async {
    if (_selected.isEmpty) return;
    if (_role != null && _role == 'admin') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Akun admin tidak dapat melakukan checkout tiket')),
      );
      return;
    }

    try {
      final storedCust = await api.getStoredCustomerId();
      if (storedCust == null) {
        // minta user untuk login ulang / sinkron
        throw Exception(
            'Customer belum tersinkron. Silakan login ulang agar akun disinkronkan.');
      }

      // NOTE: sesuaikan customerId dengan user yang login
      final res = await api.checkout(
        customerId: storedCust,
        jadwalId: widget.jadwalId,
        kursiIds: _selected.toList(),
      );

      // Fallback label kursi supaya tidak "ID" lagi
      String labels = '';
      final rawList = res['kursi'];
      if (rawList is List && rawList.isNotEmpty) {
        final items = rawList
            .map((e) => (e is Map ? e['nomor_kursi'] : null))
            .where((x) => x != null && x.toString().isNotEmpty)
            .map((x) => x.toString())
            .toList();
        labels = items.join(', ');
      }
      if (labels.isEmpty) {
        labels = (res['kursi_labels'] ?? '').toString();
      }
      if (labels.isEmpty) {
        labels = _selectedLabels;
      }

      final total = res['total_harga'] ?? _total;

      final data = {
        ...res,
        'kursi_labels': labels,
        'total_harga': total,
        'kursi': (res['kursi'] is List && (res['kursi'] as List).isNotEmpty)
            ? res['kursi']
            : _selected
                .map((id) => {
                      'kursi_id': id,
                      'nomor_kursi': _labelById(id),
                      'harga': _priceOfId(id),
                    })
                .toList(),
        'film_title': widget.filmTitle,
        'studio_name': _jadwal?['nama_studio'],
        'studio_id': _jadwal?['studio_id'] ?? widget.studioId,
        'jadwal_tanggal': _jadwal?['tanggal'],
        'jadwal_mulai': _jadwal?['jam_mulai'],
        'jadwal_selesai': _jadwal?['jam_selesai'],
        'purchase_time': DateTime.now().toIso8601String(),
        'project_name': 'Lotus Cinema',
      };

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CheckoutSuccessPage(data: data)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout gagal: $e')),
      );
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupSeatsByRow() {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final seat in _seats) {
      final label = _labelOf(seat);
      final key = label.isNotEmpty ? label[0].toUpperCase() : '?';
      map.putIfAbsent(key, () => []).add(seat);
    }
    for (final entry in map.entries) {
      entry.value.sort((a, b) {
        final na = _seatNumber(_labelOf(a));
        final nb = _seatNumber(_labelOf(b));
        return na.compareTo(nb);
      });
    }
    final sortedKeys = map.keys.toList()..sort();
    return {for (final k in sortedKeys) k: map[k]!};
  }

  int _seatNumber(String label) {
    final match = RegExp(r'\d+').firstMatch(label);
    return match == null ? 0 : int.tryParse(match.group(0)!) ?? 0;
  }

  String _formatCurrency(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final left = digits.length - i - 1;
      if (left > 0 && left % 3 == 0) buffer.write('.');
    }
    return value < 0 ? '-${buffer.toString()}' : buffer.toString();
  }

  List<Map<String, dynamic>> _rowLayouts() {
    final grouped = _groupSeatsByRow();
    final layouts = <Map<String, dynamic>>[];

    for (final cfg in _seatLayoutBlueprint) {
      final rowLabel = cfg['row'] as String;
      final leftCount = cfg['left'] as int? ?? 0;
      final rightCount = cfg['right'] as int? ?? 0;
      final centerCount = cfg['center'] as int? ?? 0;
      final totalCount = leftCount + rightCount + centerCount;
      final seats = grouped[rowLabel] ?? <Map<String, dynamic>>[];

      final seatByNumber = <int, Map<String, dynamic>>{};
      for (final seat in seats) {
        final number = _seatNumber(_labelOf(seat));
        if (number >= 1 && number <= totalCount) {
          seatByNumber[number] = seat;
        }
      }

      layouts.add({
        'row': rowLabel,
        'leftCount': leftCount,
        'rightCount': rightCount,
        'centerCount': centerCount,
        'left': List<Map<String, dynamic>?>.generate(
            leftCount, (i) => seatByNumber[i + 1]),
        'right': List<Map<String, dynamic>?>.generate(
            rightCount, (i) => seatByNumber[leftCount + i + 1]),
        'center': List<Map<String, dynamic>?>.generate(
            centerCount, (i) => seatByNumber[leftCount + rightCount + i + 1]),
      });
    }

    return layouts;
  }

  Widget _buildSeatSketch(ColorScheme cs) {
    const seatSize = 40.0;
    const seatSpacing = 5.0;
    const walkwayDefault = 40.0;
    const walkwayLarge = walkwayDefault + seatSize + seatSpacing;
    double walkwayForRow(String label) =>
        ['A', 'B', 'C', 'D'].contains(label.toUpperCase())
            ? walkwayLarge
            : walkwayDefault;

    final layouts = _rowLayouts();
    if (layouts.isEmpty) return const SizedBox.shrink();

    final maxLeft = _seatLayoutBlueprint.fold<int>(
        0, (max, cfg) => math.max(max, cfg['left'] as int? ?? 0));
    final maxRight = _seatLayoutBlueprint.fold<int>(
        0, (max, cfg) => math.max(max, cfg['right'] as int? ?? 0));
    final maxCenter = _seatLayoutBlueprint.fold<int>(
        0, (max, cfg) => math.max(max, cfg['center'] as int? ?? 0));
    final maxWalkway = _seatLayoutBlueprint.fold<double>(0, (max, cfg) {
      final row = (cfg['row'] as String?) ?? '';
      final hasLeft = (cfg['left'] as int? ?? 0) > 0;
      final hasRight = (cfg['right'] as int? ?? 0) > 0;
      if (hasLeft && hasRight) {
        return math.max(max, walkwayForRow(row));
      }
      return max;
    });

    double blockWidth(int count) =>
        count > 0 ? seatSize * count + seatSpacing * (count - 1) : 0;

    final leftBlockWidth = blockWidth(maxLeft);
    final rightBlockWidth = blockWidth(maxRight);
    final centerBlockWidth = blockWidth(maxCenter);
    final twoBlockWidth = (maxLeft > 0 && maxRight > 0)
        ? leftBlockWidth + rightBlockWidth + maxWalkway
        : leftBlockWidth + rightBlockWidth;
    final layoutWidth = math.max(twoBlockWidth, centerBlockWidth);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: layoutWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: layouts.map((row) {
              final leftSeats =
                  (row['left'] as List<Map<String, dynamic>?>?) ?? const [];
              final rightSeats =
                  (row['right'] as List<Map<String, dynamic>?>?) ?? const [];
              final centerSeats =
                  (row['center'] as List<Map<String, dynamic>?>?) ?? const [];

              final hasLeft = (row['leftCount'] as int) > 0;
              final hasRight = (row['rightCount'] as int) > 0;
              final hasCenter = (row['centerCount'] as int) > 0;
              final hasBothSides = hasLeft && hasRight;
              final rowHasCenterOnly = !hasLeft && !hasRight && hasCenter;

              Widget buildBlock(List<Map<String, dynamic>?> seats, double width,
                  ColorScheme cs) {
                return SizedBox(
                  width: width,
                  child: Wrap(
                    spacing: seatSpacing,
                    runSpacing: seatSpacing,
                    alignment: WrapAlignment.center,
                    children: seats
                        .map((seat) => seat == null
                            ? _buildSeatPlaceholder(seatSize, cs)
                            : _buildSeatTile(seat, cs, seatSize))
                        .toList(),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SizedBox(
                  width: layoutWidth,
                  child: rowHasCenterOnly
                      ? Align(
                          alignment: Alignment.center,
                          child: buildBlock(
                              centerSeats, blockWidth(centerSeats.length), cs),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasLeft)
                              buildBlock(
                                  leftSeats, blockWidth(leftSeats.length), cs),
                            if (hasBothSides)
                              SizedBox(width: walkwayForRow(row['row'])),
                            if (hasRight)
                              buildBlock(rightSeats,
                                  blockWidth(rightSeats.length), cs),
                          ],
                        ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(ColorScheme cs) {
    final prices = _seats
        .map((s) => _asInt(s['harga']))
        .where((v) => v > 0)
        .toSet()
        .toList()
      ..sort();
    String priceText;
    if (prices.isEmpty) {
      priceText = 'Tidak ada harga';
    } else if (prices.length == 1) {
      priceText = 'Rp ${_formatCurrency(prices.first)}';
    } else {
      priceText = prices.map((p) => 'Rp ${_formatCurrency(p)}').join(' / ');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Keterangan',
            style:
                TextStyle(fontWeight: FontWeight.w700, color: cs.onBackground)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            _legendItem(color: cs.surface, label: 'Tersedia', cs: cs),
            _legendItem(color: cs.surfaceVariant, label: 'Terjual', cs: cs),
            _legendItem(color: cs.primaryContainer, label: 'Dipilih', cs: cs),
          ],
        ),
        const SizedBox(height: 12),
        Text('Harga tiket: $priceText',
            style: TextStyle(color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        Text(
          'Catatan : Silahkan pilih kursi sesuai keinginan Anda, dan jangan lupa untuk melakukan konfirmasi sebelum melanjutkan.',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _legendItem(
      {required Color color, required String label, required ColorScheme cs}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: cs.outlineVariant)),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: cs.onSurface)),
      ],
    );
  }

  Widget _buildSeatPlaceholder(double size, ColorScheme cs) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(.3)),
      ),
    );
  }

  Widget _buildSeatTile(Map<String, dynamic> seat, ColorScheme cs,
      [double size = 42]) {
    final seatId = (seat['kursi_id'] is num)
        ? (seat['kursi_id'] as num).toInt()
        : int.tryParse('${seat['kursi_id']}') ?? 0;
    final sold = _isSold(seat);
    final selected = _selected.contains(seatId);
    final background = sold
        ? cs.surfaceVariant
        : selected
            ? cs.primaryContainer
            : cs.surface;
    final borderColor = sold
        ? cs.outlineVariant
        : selected
            ? cs.primary
            : cs.outlineVariant;

    return InkWell(
      onTap: sold
          ? null
          : () {
              setState(() {
                if (selected) {
                  _selected.remove(seatId);
                } else {
                  _selected.add(seatId);
                }
              });
            },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.4),
          boxShadow: sold
              ? null
              : [
                  BoxShadow(
                    color: (selected ? cs.primary : cs.shadow)
                        .withOpacity(selected ? .25 : .08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          _labelOf(seat),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10,
            color: sold
                ? cs.outline
                : selected
                    ? cs.onPrimaryContainer
                    : cs.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniSeatBox(Map<String, dynamic>? seat, ColorScheme cs) {
    const miniSeat = 16.0;
    Color bg;
    Color border = cs.outlineVariant.withOpacity(.6);

    if (seat == null) {
      bg = cs.surfaceVariant.withOpacity(.12);
      border = cs.outlineVariant.withOpacity(.3);
    } else {
      final seatId = (seat['kursi_id'] is num)
          ? (seat['kursi_id'] as num).toInt()
          : int.tryParse('${seat['kursi_id']}') ?? 0;
      final sold = _isSold(seat);
      final selected = _selected.contains(seatId);

      if (selected) {
        bg = cs.primaryContainer;
        border = cs.primary;
      } else if (sold) {
        bg = cs.surfaceVariant;
        border = cs.outlineVariant;
      } else {
        bg = cs.surface;
      }
    }

    return Container(
      width: miniSeat,
      height: miniSeat,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
    );
  }

  Widget _buildStudioDenah(ColorScheme cs) {
    const miniSeat = 16.0;
    const miniSpacing = 6.0;
    const miniWalkwayDefault = 28.0;
    const miniWalkwayLarge = miniWalkwayDefault + miniSeat + miniSpacing;
    const doorColumnSpacing = 8.0;
    const extraDoorAllowance = 0.0;
    double rowWalkway(String label) =>
        ['A', 'B', 'C', 'D'].contains(label.toUpperCase())
            ? miniWalkwayLarge
            : miniWalkwayDefault;

    final layouts = _rowLayouts();

    final maxLeft = _seatLayoutBlueprint.fold<int>(
        0, (max, cfg) => math.max(max, cfg['left'] as int? ?? 0));
    final maxRight = _seatLayoutBlueprint.fold<int>(
        0, (max, cfg) => math.max(max, cfg['right'] as int? ?? 0));
    final maxCenter = _seatLayoutBlueprint.fold<int>(
        0, (max, cfg) => math.max(max, cfg['center'] as int? ?? 0));
    final maxWalkway = _seatLayoutBlueprint.fold<double>(0, (max, cfg) {
      final row = (cfg['row'] as String?) ?? '';
      final hasLeft = (cfg['left'] as int? ?? 0) > 0;
      final hasRight = (cfg['right'] as int? ?? 0) > 0;
      if (hasLeft && hasRight) {
        return math.max(max, rowWalkway(row));
      }
      return max;
    });

    double blockWidth(int count) =>
        count > 0 ? miniSeat * count + miniSpacing * (count - 1) : 0;

    final leftBlockWidth = blockWidth(maxLeft);
    final rightBlockWidth = blockWidth(maxRight);
    final centerBlockWidth = blockWidth(maxCenter);
    final twoBlockWidth = (maxLeft > 0 && maxRight > 0)
        ? leftBlockWidth + rightBlockWidth + maxWalkway
        : leftBlockWidth + rightBlockWidth;
    final seatAreaWidth = math.max(twoBlockWidth, centerBlockWidth);
    const doorWidth = 32.0;
    final containerWidth =
        seatAreaWidth + doorWidth + doorColumnSpacing + extraDoorAllowance + 32;

    Widget buildMiniBlock(List<Map<String, dynamic>?> seats, double width) {
      return SizedBox(
        width: width,
        child: Wrap(
          spacing: miniSpacing,
          runSpacing: miniSpacing,
          alignment: WrapAlignment.center,
          children: seats.map((seat) => _buildMiniSeatBox(seat, cs)).toList(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Denah Studio',
            style:
                TextStyle(fontWeight: FontWeight.w700, color: cs.onBackground)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: containerWidth,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: seatAreaWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: seatAreaWidth,
                          height: 32,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cs.primary),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'LAYAR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.8,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...layouts.map((row) {
                          final rowLabel = (row['row'] as String?) ?? '';
                          final walkwaySpacing = rowWalkway(rowLabel);
                          final leftSeats =
                              (row['left'] as List<Map<String, dynamic>?>?) ??
                                  const [];
                          final rightSeats =
                              (row['right'] as List<Map<String, dynamic>?>?) ??
                                  const [];
                          final centerSeats =
                              (row['center'] as List<Map<String, dynamic>?>?) ??
                                  const [];

                          final leftCount = row['leftCount'] as int;
                          final rightCount = row['rightCount'] as int;
                          final centerCount = row['centerCount'] as int;
                          final hasLeft = leftCount > 0;
                          final hasRight = rightCount > 0;
                          final hasCenter = centerCount > 0;
                          final hasBothSides = hasLeft && hasRight;
                          final rowHasCenterOnly =
                              !hasLeft && !hasRight && hasCenter;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: SizedBox(
                              width: seatAreaWidth,
                              child: rowHasCenterOnly
                                  ? Align(
                                      alignment: Alignment.center,
                                      child: buildMiniBlock(centerSeats,
                                          blockWidth(centerSeats.length)),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (hasLeft)
                                          buildMiniBlock(leftSeats,
                                              blockWidth(leftSeats.length)),
                                        if (hasBothSides)
                                          SizedBox(width: walkwaySpacing),
                                        if (hasRight)
                                          buildMiniBlock(rightSeats,
                                              blockWidth(rightSeats.length)),
                                      ],
                                    ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: doorColumnSpacing),
                  _buildDenahDoor(cs),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDenahDoor(ColorScheme cs) {
    return Column(
      children: [
        const SizedBox(height: 44),
        Container(
          width: 32,
          height: 64,
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.primary),
          ),
          alignment: Alignment.center,
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              'PINTU',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppTheme.buildGradientAppBar(
        context,
        'Pilih Kursi • ${widget.filmTitle}',
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_role == 'admin')
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Catatan: akun admin tidak dapat melakukan pembelian tiket.',
                    style: TextStyle(color: Colors.red.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),
              Text('Kursi: $_selectedLabels',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                      child: Text(
                          'Dipilih: ${_selected.length}  |  Total: Rp $_total')),
                  FilledButton.icon(
                    onPressed: (_selected.isEmpty || _role == 'admin')
                        ? null
                        : _checkout,
                    icon: const Icon(Icons.payment),
                    label: const Text('Checkout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : (_seats.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          widget.studioId == null
                              ? 'Belum ada kursi untuk jadwal ini.\nStudioId tidak diketahui, silakan tambah kursi di server.'
                              : 'Belum ada kursi.\nTekan kembali lalu masuk lagi, atau gunakan tombol Checkout setelah memilih kursi virtual.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Silahkan pilih kursi :',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: cs.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSeatSketch(cs),
                          _buildStudioDenah(cs),
                          _buildLegend(cs),
                          const SizedBox(height: 24),
                        ],
                      ),
                    )),
    );
  }
}
