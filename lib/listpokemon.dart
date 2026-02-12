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
  String _ownedFilter = 'Semua';
  String _setFilter = 'Semua';
  String _rarityFilter = 'Semua';
  int _navIndex = 2;

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

    bool matchesOwned(CardItem item) {
      switch (_ownedFilter) {
        case 'Owned':
          return item.owned;
        case 'Wish':
          return !item.owned;
        default:
          return true;
      }
    }

    bool matchesSet(CardItem item) {
      if (_setFilter == 'Semua') return true;
      return item.setName == _setFilter;
    }

    bool matchesRarity(CardItem item) {
      if (_rarityFilter == 'Semua') return true;
      return item.rarity.toLowerCase().contains(_rarityFilter.toLowerCase());
    }

    return items.where((item) {
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.setName.toLowerCase().contains(query);
      return matchesQuery &&
          matchesFilter(item) &&
          matchesOwned(item) &&
          matchesSet(item) &&
          matchesRarity(item);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // List yang sudah diproses filter.
    final filteredItems = _applyFilters(_items);

    return Scaffold(
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
            child: Column(
              children: [
                // Header + search + filter chips.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.collections_bookmark,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Koleksi Kartu',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Kelola dan cari kartu favoritmu',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.tune),
                              onPressed: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  showDragHandle: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (context) {
                                    String tempFilter = _filter;
                                    String tempOwned = _ownedFilter;
                                    String tempSet = _setFilter;
                                    String tempRarity = _rarityFilter;
                                    final setOptions = <String>{
                                      'Semua',
                                      ..._items.map((item) => item.setName),
                                    }.toList();
                                    final rarityOptions = <String>{
                                      'Semua',
                                      ..._items.map((item) => item.rarity),
                                    }.toList();
                                    return StatefulBuilder(
                                      builder: (context, sheetSetState) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            20,
                                            8,
                                            20,
                                            24,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Filter Koleksi',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Status',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  _FilterChip(
                                                    label: 'Semua',
                                                    selected:
                                                        tempOwned == 'Semua',
                                                    onTap: () {
                                                      sheetSetState(() {
                                                        tempOwned = 'Semua';
                                                      });
                                                    },
                                                  ),
                                                  _FilterChip(
                                                    label: 'Owned',
                                                    selected:
                                                        tempOwned == 'Owned',
                                                    onTap: () {
                                                      sheetSetState(() {
                                                        tempOwned = 'Owned';
                                                      });
                                                    },
                                                  ),
                                                  _FilterChip(
                                                    label: 'Wish',
                                                    selected:
                                                        tempOwned == 'Wish',
                                                    onTap: () {
                                                      sheetSetState(() {
                                                        tempOwned = 'Wish';
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Rarity',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: rarityOptions
                                                    .map(
                                                      (rarity) => _FilterChip(
                                                        label: rarity,
                                                        selected:
                                                            tempRarity == rarity,
                                                        onTap: () {
                                                          sheetSetState(() {
                                                            tempRarity = rarity;
                                                          });
                                                        },
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Set',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: setOptions
                                                    .map(
                                                      (setName) => _FilterChip(
                                                        label: setName,
                                                        selected:
                                                            tempSet == setName,
                                                        onTap: () {
                                                          sheetSetState(() {
                                                            tempSet = setName;
                                                          });
                                                        },
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                              const SizedBox(height: 16),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  _FilterChip(
                                                    label: 'Semua',
                                                    selected:
                                                        tempFilter == 'Semua',
                                                    onTap: () {
                                                      sheetSetState(() {
                                                        tempFilter = 'Semua';
                                                      });
                                                    },
                                                  ),
                                                  _FilterChip(
                                                    label: 'Rare',
                                                    selected:
                                                        tempFilter == 'Rare',
                                                    onTap: () {
                                                      sheetSetState(() {
                                                        tempFilter = 'Rare';
                                                      });
                                                    },
                                                  ),
                                                  _FilterChip(
                                                    label: 'Holo',
                                                    selected:
                                                        tempFilter == 'Holo',
                                                    onTap: () {
                                                      sheetSetState(() {
                                                        tempFilter = 'Holo';
                                                      });
                                                    },
                                                  ),
                                                  _FilterChip(
                                                    label: 'Promo',
                                                    selected:
                                                        tempFilter == 'Promo',
                                                    onTap: () {
                                                      sheetSetState(() {
                                                        tempFilter = 'Promo';
                                                      });
                                                    },
                                                  ),
                                                  _FilterChip(
                                                    label: 'Duplikat',
                                                    selected:
                                                        tempFilter == 'Duplikat',
                                                    onTap: () {
                                                      sheetSetState(() {
                                                        tempFilter =
                                                            'Duplikat';
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _filter = 'Semua';
                                                          _ownedFilter =
                                                              'Semua';
                                                          _setFilter = 'Semua';
                                                          _rarityFilter =
                                                              'Semua';
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child:
                                                          const Text('Reset'),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _filter = tempFilter;
                                                          _ownedFilter =
                                                              tempOwned;
                                                          _setFilter = tempSet;
                                                          _rarityFilter =
                                                              tempRarity;
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                                0xFF101828),
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                      child:
                                                          const Text('Terapkan'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            const Icon(Icons.search, color: Colors.black45),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Cari nama kartu atau set',
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  setState(() => _search = value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _items.isEmpty
                          ? const Center(
                              child: Text('Belum ada kartu. Tambah dulu ya!'),
                            )
                          : filteredItems.isEmpty
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
                                        final result =
                                            await Navigator.of(context)
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
                                        if (result == null ||
                                            !context.mounted) {
                                          return;
                                        }
                                        final updated = item.copyWith(
                                          name: result['name'] as String,
                                          setName: result['set'] as String,
                                          number: result['number'] as String,
                                          rarity: result['rarity'] as String,
                                          owned: result['owned'] as bool,
                                          imagePath:
                                              result['imagePath'] as String?,
                                        );
                                        await CardRepository.instance
                                            .update(updated);
                                        await _load();
                                      },
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CardDetailPage(
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
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF101828),
        unselectedItemColor: const Color(0xFF98A2B3),
        showUnselectedLabels: true,
        elevation: 12,
        currentIndex: _navIndex,
        onTap: (index) {
          if (index == 2) {
            setState(() => _navIndex = 2);
            return;
          }
          if (index == 0) {
            Navigator.of(context).pop();
            return;
          }
          setState(() => _navIndex = index);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu belum tersedia.')),
          );
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
