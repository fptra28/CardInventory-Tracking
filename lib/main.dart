import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'card_repository.dart';
import 'explore_page.dart';
import 'listPokemon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF101828),
          onPrimary: Colors.white,
          secondary: Color(0xFFFFD166),
          onSecondary: Color(0xFF101828),
          error: Color(0xFFB42318),
          onError: Colors.white,
          surface: Color(0xFFF9FAFB),
          onSurface: Color(0xFF101828),
          background: Color(0xFFF2F4F7),
          onBackground: Color(0xFF101828),
        ),
      ),
      home: const MyHomePage(title: 'PokeCard Vault'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<CardItem> _items = [];
  bool _loading = true;
  String? _errorMessage;
  int _navIndex = 0;
  late final PageController _setPageController =
      PageController(viewportFraction: 0.92, initialPage: _setPageIndex);
  Timer? _setAutoTimer;
  int _setPageIndex = 10000;
  List<String> _setNames = [];
  Map<String, int> _setCounts = {};

  @override
  void initState() {
    super.initState();
    _load();
    _setAutoTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || _setNames.length <= 1) {
        return;
      }
      _setPageIndex += 1;
      _setPageController.animateToPage(
        _setPageIndex,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _setAutoTimer?.cancel();
    _setPageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await CardRepository.instance.getAll();
      if (!mounted) return;
      _rebuildSetSummary(items);
      setState(() {
        _items = items;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  void _rebuildSetSummary(List<CardItem> items) {
    final counts = <String, int>{};
    final names = <String>[];
    for (final item in items) {
      counts[item.setName] = (counts[item.setName] ?? 0) + 1;
      if (!names.contains(item.setName)) {
        names.add(item.setName);
      }
    }
    _setCounts = counts;
    _setNames = names;
    if (_setNames.isEmpty) {
      _setPageIndex = 10000;
    }
  }

  int _countRare(List<CardItem> items) {
    int count = 0;
    for (final item in items) {
      final rarity = item.rarity.toLowerCase();
      if (rarity.contains('rare') ||
          rarity.contains('rr') ||
          rarity.contains('sr') ||
          rarity.contains('ur') ||
          rarity.contains('hr') ||
          rarity.contains('sir') ||
          rarity.contains('sar')) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final total = _items.length;
    final rareCount = _countRare(_items);
    final ownedCount = _items.where((item) => item.owned).length;
    final recentItems =
        _items.length <= 3 ? _items : _items.sublist(0, 3);

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF101828),
        unselectedItemColor: const Color(0xFF98A2B3),
        showUnselectedLabels: true,
        elevation: 12,
        currentIndex: _navIndex,
        onTap: (index) async {
          if (index == 0) {
            setState(() => _navIndex = 0);
            return;
          }
          if (index == 2) {
            setState(() => _navIndex = 2);
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NewPage(),
              ),
            );
            if (!mounted) return;
            setState(() => _navIndex = 0);
            await _load();
            return;
          }
          if (index == 1) {
            setState(() => _navIndex = 1);
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ExplorePage(),
              ),
            );
            if (!mounted) return;
            setState(() => _navIndex = 0);
            return;
          }
          setState(() => _navIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark_outlined),
            activeIcon: Icon(Icons.collections_bookmark),
            label: 'Koleksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF3C4),
                  Color(0xFFEFF4FF),
                  Color(0xFFFBE8FF),
                ],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD166).withOpacity(0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -40,
            child: Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF9B8BFF).withOpacity(0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.catching_pokemon, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Tracking koleksi kartu Pokemon',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_none),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Koleksimu semakin besar.',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Simpan, tandai, dan pantau kartu yang sudah kamu punya.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatCard(
                        title: 'Total Kartu',
                        value: total.toString(),
                        color: const Color(0xFF101828),
                        accent: const Color(0xFFFFD166),
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        title: 'Rare',
                        value: rareCount.toString(),
                        color: const Color(0xFF101828),
                        accent: const Color(0xFF9B8BFF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_setNames.isEmpty)
                    const _SetSummaryCard(title: 'Set Kanto', count: 0)
                  else
                    SizedBox(
                      height: 140,
                      child: PageView.builder(
                        controller: _setPageController,
                        clipBehavior: Clip.none,
                        padEnds: false,
                        onPageChanged: (index) {
                          _setPageIndex = index;
                        },
                        itemBuilder: (context, index) {
                          if (_setNames.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final realIndex = index % _setNames.length;
                          final setName = _setNames[realIndex];
                          final count = _setCounts[setName] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12, bottom: 8),
                            child: _SetSummaryCard(
                              title: setName,
                              count: count,
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (_loading || _errorMessage != null || recentItems.isNotEmpty) ...[
                    Text(
                      'Terbaru Ditambahkan',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 156,
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _errorMessage != null
                              ? Center(
                                  child: Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: recentItems
                                      .map(
                                        (item) => _MiniCard(
                                          name: item.name,
                                          setName: item.setName,
                                          accent: Color(item.accent),
                                          imagePath: item.imagePath,
                                        ),
                                      )
                                      .toList(),
                                ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kelola Koleksimu',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tambah kartu baru, tandai duplikat, dan buat catatan.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const NewPage(),
                              ),
                            );
                            if (!mounted) return;
                            setState(() {
                              _loading = true;
                              _errorMessage = null;
                            });
                            await _load();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF101828),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Lihat Koleksi'),
                        ),
                      ],
                    ),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.accent,
  });

  final String title;
  final String value;
  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    required this.progressLabel,
    required this.progress,
  });

  final String title;
  final String progressLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            progressLabel,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE4E7EC),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF101828)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetSummaryCard extends StatelessWidget {
  const _SetSummaryCard({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final accent = count == 0 ? const Color(0xFF98A2B3) : const Color(0xFF101828);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF6F4FF),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.collections_bookmark,
              color: accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count kartu',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.name,
    required this.setName,
    required this.accent,
    required this.imagePath,
  });

  final String name;
  final String setName;
  final Color accent;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: accent.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: imagePath == null
                ? const Icon(Icons.auto_awesome, size: 28)
                : Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image_outlined, size: 28);
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            setName,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
