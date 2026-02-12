import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CardFormPage extends StatefulWidget {
  const CardFormPage({
    super.key,
    this.initialName,
    this.initialSet,
    this.initialNumber,
    this.initialRarity,
    this.initialOwned = false,
    this.initialImagePath,
  });

  final String? initialName;
  final String? initialSet;
  final String? initialNumber;
  final String? initialRarity;
  final bool initialOwned;
  final String? initialImagePath;

  bool get isEditing => initialName != null;

  @override
  State<CardFormPage> createState() => _CardFormPageState();
}

class _CardFormPageState extends State<CardFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _setController = TextEditingController();
  final _numberController = TextEditingController();
  bool _owned = false;
  String? _rarity;
  String? _imagePath;
  final _imagePicker = ImagePicker();

  static const _rarityOptions = <String>[
    'Common (C)',
    'Uncommon (UC)',
    'Rare (R)',
    'Double Rare (RR)',
    'Triple Rare (RRR)',
    'Holo (H)',
    'Alternative Art (AA)',
    'Art Rare (AR)',
    'Character Rare (CHR)',
    'Character Super Rare (CSR)',
    'Illustrator Rare (IR)',
    'Special Illustration Rare (SIR)',
    'Special Art Rare (SAR)',
    'Super Rare (SR)',
    'Hyper Rare (HR)',
    'Ultra Rare (UR)',
    'Shiny Super Rare (SSR)',
    'Mega Attack Rare (MA)',
    'Mega Ultra Rare (MUR)',
    'Promo (PR)',
    'Radiant (K)',
    'Ace Spec (AS)',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _setController.text = widget.initialSet ?? '';
    _numberController.text = widget.initialNumber ?? '';
    _rarity = widget.initialRarity;
    _owned = widget.initialOwned;
    _imagePath = widget.initialImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'set': _setController.text.trim(),
      'number': _numberController.text.trim(),
      'rarity': _rarity?.trim() ?? '',
      'owned': _owned,
      'imagePath': _imagePath,
    });
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) {
      return;
    }
    setState(() => _imagePath = picked.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Kartu' : 'Tambah Kartu'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionCard(
                  title: 'Detail Kartu',
                  child: Column(
                    children: [
                      _ImagePickerCard(
                        imagePath: _imagePath,
                        onPick: _pickImage,
                      ),
                      const SizedBox(height: 12),
                      _InputField(
                        controller: _nameController,
                        label: 'Nama Kartu',
                        hint: 'Contoh: Pikachu VMAX',
                      ),
                      const SizedBox(height: 12),
                      _InputField(
                        controller: _setController,
                        label: 'Set',
                        hint: 'Contoh: Vivid Voltage',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InputField(
                              controller: _numberController,
                              label: 'Nomor',
                              hint: 'Contoh: #188',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DropdownField(
                              label: 'Rarity',
                              hint: 'Pilih rarity',
                              value: _rarity,
                              items: _rarityOptions,
                              onChanged: (value) {
                                setState(() => _rarity = value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Status Koleksi',
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _owned ? 'Sudah Dimiliki' : 'Belum Dimiliki',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Switch(
                        value: _owned,
                        onChanged: (value) {
                          setState(() => _owned = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF101828),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      widget.isEditing ? 'Simpan Perubahan' : 'Tambah',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label wajib diisi';
        }
        return null;
      },
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) => items
          .map(
            (item) => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label wajib diisi';
        }
        return null;
      },
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({
    required this.imagePath,
    required this.onPick,
  });

  final String? imagePath;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 72,
                width: 52,
                color: const Color(0xFFF2F4F7),
                child: imagePath == null
                    ? const Icon(Icons.image, size: 26, color: Colors.black45)
                    : Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image_outlined,
                            size: 26,
                            color: Colors.black45,
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    imagePath == null ? 'Tambah Foto Kartu' : 'Ganti Foto',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap untuk pilih dari galeri',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
