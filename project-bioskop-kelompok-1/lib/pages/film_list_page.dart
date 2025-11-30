import 'package:flutter/material.dart';
import '../api_service.dart';
import '../theme/app_theme.dart';
import '../theme/bubble_container.dart';
import 'film_form_page.dart';
import 'film_detail_page.dart';

class FilmListPage extends StatefulWidget {
  const FilmListPage({super.key});

  @override
  State<FilmListPage> createState() => _FilmListPageState();
}

class _FilmListPageState extends State<FilmListPage> {
  final api = ApiService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _load();
  }

  Future<void> _loadRole() async {
    final r = await api.getStoredRole();
    if (!mounted) return;
    setState(() => _isAdmin = (r == 'admin'));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await api.films(perPage: 200);
      final list = res.data
          .map<Map<String, dynamic>>(
            (e) => Map<String, dynamic>.from(e as Map),
          )
          .toList();
      setState(() => _items = list);
    } catch (e) {
      setState(() => _error = 'Gagal memuat film: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  dynamic _filmIdOf(Map<String, dynamic> m) {
    final raw = m['film_id'] ?? m['id'] ?? m['ID'];
    if (raw is int) return raw;
    return int.tryParse('$raw');
  }

  String _titleOf(Map<String, dynamic> m) {
    return (m['judul'] ?? m['title'] ?? 'Tanpa Judul').toString();
  }

  String _durationOf(Map<String, dynamic> m) {
    final raw = m['durasi'];
    if (raw == null) return '-';
    final parsed = int.tryParse(raw.toString());
    return parsed == null ? raw.toString() : parsed.toString();
  }

  String _genreLabel(Map<String, dynamic> m) {
    final g = (m['genre_name'] ?? m['genre_nama'] ?? m['genre'])?.toString();
    if (g != null && g.isNotEmpty) return g;
    final id = m['genre_id'] ?? m['id_genre'];
    return id == null ? '-' : 'ID $id';
  }

  int _gridCountForWidth(double width) {
    if (width < 360) return 1;
    if (width < 640) return 2;
    if (width < 900) return 3;
    return 4;
  }

  double _childAspectRatioForWidth(double width) {
    // Perkiraan proporsi yang nyaman untuk poster+teks
    if (width < 360) return 0.62; // kartu lebih tinggi di layar kecil
    if (width < 640) return 0.66;
    if (width < 900) return 0.70;
    return 0.75;
  }

  /// URL poster ke backend /poster/<filename>
  String? _posterUrl(Map<String, dynamic> m) {
    final assetUrl = m['poster_asset_url'] as String?;
    if (assetUrl != null && assetUrl.trim().isNotEmpty) {
      return api.resolvePosterUrl(assetUrl.trim());
    }

    final raw = (m['poster_path'] ?? m['poster'])?.toString().trim();
    if (raw == null || raw.isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return api.resolvePosterUrl(raw);
    }

    String filename;
    if (raw.contains('/')) {
      filename = raw.split('/').last;
    } else {
      filename = raw;
    }

    final url = '${api.baseUrl}/poster/$filename';
    return api.resolvePosterUrl(url);
  }

  Widget _posterContent(Map<String, dynamic> film) {
    final url = _posterUrl(film);

    Widget placeholder(Color color, IconData icon) => Container(
          color: color,
          child: Icon(icon, size: 48, color: Colors.black45),
        );

    Widget content;
    if (url == null) {
      content = placeholder(Colors.black12, Icons.movie_creation_outlined);
    } else {
      content = Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (ctx, child, progress) => progress == null
            ? child
            : placeholder(Colors.grey.shade200, Icons.image_outlined),
        errorBuilder: (_, __, ___) =>
            placeholder(Colors.black12, Icons.movie_creation_outlined),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: content,
        ),
        if (_isAdmin)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    color: Colors.white,
                    tooltip: 'Edit',
                    onPressed: () => _edit(film),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    color: Colors.white,
                    tooltip: 'Hapus',
                    onPressed: () => _delete(film),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _create() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FilmFormPage()),
    );
    if (saved == true) _load();
  }

  Future<void> _edit(Map<String, dynamic> film) async {
    final id = _filmIdOf(film);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID film tidak valid')),
      );
      return;
    }
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FilmFormPage(
          filmId: id as int,
          initial: Map<String, dynamic>.from(film),
        ),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(Map<String, dynamic> film) async {
    final id = _filmIdOf(film);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID film tidak valid')),
      );
      return;
    }
    final sure = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Film'),
            content: Text('Yakin ingin menghapus "${_titleOf(film)}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;

    if (!sure) return;

    try {
      await api.deleteFilm(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Film dihapus')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppTheme.buildGradientAppBar(
        context,
        'Daftar Film',
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
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _items.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Belum ada film.')),
                          ],
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final count = _gridCountForWidth(width);
                            final aspect = _childAspectRatioForWidth(width);

                            return GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                              itemCount: _items.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: count,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: aspect,
                              ),
                              itemBuilder: (context, i) {
                                final film = _items[i];
                                final id = _filmIdOf(film);

                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 4,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: id == null
                                        ? null
                                        : () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => FilmDetailPage(
                                                  filmId: id as int,
                                                  initial: film,
                                                ),
                                              ),
                                            ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Proporsi poster vs teks: 3 : 2
                                          Expanded(
                                            flex: 3,
                                            child: _posterContent(film),
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  _titleOf(film),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Durasi: ${_durationOf(film)} m',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                                Text(
                                                  'Genre: ${_genreLabel(film)}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
    );
  }
}
