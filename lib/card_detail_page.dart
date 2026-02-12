import 'dart:io';

import 'package:flutter/material.dart';
import 'card_repository.dart';

class CardDetailPage extends StatelessWidget {
  const CardDetailPage({super.key, required this.item});

  final CardItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(title: const Text('Detail Kartu')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 360,
                    width: 260,
                    color: Color(item.accent).withOpacity(0.35),
                    child: item.imagePath == null
                        ? const Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.black45,
                          )
                        : Image.file(
                            File(item.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image_outlined,
                                size: 70,
                                color: Colors.black45,
                              );
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${item.setName} - ${item.number}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Tag(label: item.rarity, color: Color(item.accent)),
                  const SizedBox(width: 8),
                  _Tag(
                    label: item.owned ? 'Owned' : 'Wish',
                    color: item.owned
                        ? const Color(0xFF12B76A)
                        : const Color(0xFFF79009),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _DetailRow(label: 'Set', value: item.setName),
              const SizedBox(height: 8),
              _DetailRow(label: 'Nomor', value: item.number),
              const SizedBox(height: 8),
              _DetailRow(label: 'Rarity', value: item.rarity),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
