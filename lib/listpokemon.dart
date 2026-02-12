import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'add_card_page.dart';
import 'card_detail_page.dart';
import 'card_repository.dart';
import 'edit_card_page.dart';

class NewPage extends StatefulWidget {
  const NewPage({super.key});

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  // Data kartu yang tersimpan di database.
  List<CardItem> _items = [];
  // Status loading saat fetch data dari DB.
  bool _loading = true;
  // Teks pencarian untuk filter list.
  String _search = '';
  // Filter chip yang sedang aktif.
  String _filter = 'Semua';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Ambil semua data dari database.
    final items = await CardRepository.instance.getAll();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  int _randomAccent() {
    // Pilih warna aksen acak untuk tampilan kartu.
    const options = <int>[
      0xFFFFD166,
      0xFFFF9AA2,
      0xFF9B8BFF,
      0xFF7BDFF2,
      0xFF80ED99,
      0xFFFEC89A,
    ];
    return options[Random().nextInt(options.length)];
  }

  List<CardItem> _applyFilters(List<CardItem> items) {
    // Terapkan filter search + chip + deteksi duplikat.
    final query = _search.trim().toLowerCase();
    final duplicateKeys = <String, int>{};
    for (final item in items) {
      final key = '${item.name}|${item.setName}|${item.number}'.toLowerCase();
      duplicateKeys[key] = (duplicateKeys[key] ?? 0) + 1;
    }

    bool matchesFilter(CardItem item) {
      switch (_filter) {
        case 'Rare':
          return item.rarity.toLowerCase().contains('rare');
        case 'Holo':
          return item.rarity.toLowerCase().contains('holo');
        case 'Promo':
          return item.rarity.toLowerCase().contains('promo');
        case 'Duplikat':
          final key =
              '${item.name}|${item.setName}|${item.number}'.toLowerCase();
          return (duplicateKeys[key] ?? 0) > 1;
        default:
          return true;
      }
    }

    return items.where((item) {
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.setName.toLowerCase().contains(query);
      return matchesQuery && matchesFilter(item);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // List yang sudah diproses filter.
    final filteredItems = _applyFilters(_items);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      // Tombol tambah kartu.
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push<Map<String, dynamic>>(
            MaterialPageRoute(builder: (context) => const AddCardPage()),
          );
          if (result == null || !context.mounted) {
            return;
          }
          final newItem = CardItem(
            name: result['name'] as String,
            setName: result['set'] as String,
            number: result['number'] as String,
            rarity: result['rarity'] as String,
            owned: result['owned'] as bool,
            accent: _randomAccent(),
            imagePath: result['imagePath'] as String?,
          );
          await CardRepository.instance.insert(newItem);
          await _load();
        },
        backgroundColor: const Color(0xFF101828),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? const Center(
                    child: Text('Belum ada kartu. Tambah dulu ya!'),
                  )
                : Column(
                    children: [
                      // Header + search + filter chips.
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Koleksi Kartu',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Container(
                                  height: 38,
                                  width: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.tune),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Cari nama kartu atau set',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() => _search = value);
                              },
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 38,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _FilterChip(
                                    label: 'Semua',
                                    selected: _filter == 'Semua',
                                    onTap: () {
                                      setState(() => _filter = 'Semua');
                                    },
                                  ),
                                  _FilterChip(
                                    label: 'Rare',
                                    selected: _filter == 'Rare',
                                    onTap: () {
                                      setState(() => _filter = 'Rare');
                                    },
                                  ),
                                  _FilterChip(
                                    label: 'Holo',
                                    selected: _filter == 'Holo',
                                    onTap: () {
                                      setState(() => _filter = 'Holo');
                                    },
                                  ),
                                  _FilterChip(
                                    label: 'Promo',
                                    selected: _filter == 'Promo',
                                    onTap: () {
                                      setState(() => _filter = 'Promo');
                                    },
                                  ),
                                  _FilterChip(
                                    label: 'Duplikat',
                                    selected: _filter == 'Duplikat',
                                    onTap: () {
                                      setState(() => _filter = 'Duplikat');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filteredItems.isEmpty
                            ? const Center(
                                child: Text('Tidak ada kartu yang cocok.'),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  return _CardTile(
                                    item: filteredItems[index],
                                    onEdit: (item) async {
                                      final result = await Navigator.of(context)
                                          .push<Map<String, dynamic>>(
                                        MaterialPageRoute(
                                          builder: (context) => EditCardPage(
                                            initialName: item.name,
                                            initialSet: item.setName,
                                            initialNumber: item.number,
                                            initialRarity: item.rarity,
                                            initialOwned: item.owned,
                                            initialImagePath: item.imagePath,
                                          ),
                                        ),
                                      );
                                      if (result == null || !context.mounted) {
                                        return;
                                      }
                                      final updated = item.copyWith(
                                        name: result['name'] as String,
                                        setName: result['set'] as String,
                                        number: result['number'] as String,
                                        rarity: result['rarity'] as String,
                                        owned: result['owned'] as bool,
                                        imagePath: result['imagePath'] as String?,
                                      );
                                      await CardRepository.instance
                                          .update(updated);
                                      await _load();
                                    },
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => CardDetailPage(
                                            item: filteredItems[index],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.item, required this.onEdit, required this.onTap});

  final CardItem item;
  final Future<void> Function(CardItem item) onEdit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Item kartu di list.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 80,
                width: 58,
                color: Color(item.accent).withOpacity(0.35),
                child: item.imagePath == null
                    ? const Icon(Icons.image, size: 24, color: Colors.black45)
                    : Image.file(
                        File(item.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image_outlined,
                            size: 24,
                            color: Colors.black45,
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.setName} - ${item.number}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Tag(label: item.rarity, color: Color(item.accent)),
                      const SizedBox(width: 8),
                      if (item.owned)
                        const _Tag(
                          label: 'Owned',
                          color: Color(0xFF12B76A),
                        )
                      else
                        const _Tag(
                          label: 'Wish',
                          color: Color(0xFFF79009),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  item.owned ? Icons.check_circle : Icons.add_circle_outline,
                  color: item.owned ? const Color(0xFF12B76A) : Colors.black54,
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    await onEdit(item);
                  },
                  child: const Icon(Icons.edit, color: Colors.black54, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Chip filter untuk list kartu.
    final chipColor = selected ? const Color(0xFF101828) : Colors.white;
    final textColor = selected ? Colors.white : const Color(0xFF101828);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontWeight: FontWeight.w600, color: textColor),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Tag kecil untuk rarity/owned.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
