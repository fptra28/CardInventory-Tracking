import 'package:flutter/material.dart';
import 'card_form_page.dart';

class EditCardPage extends StatelessWidget {
  const EditCardPage({
    super.key,
    required this.initialName,
    required this.initialSet,
    required this.initialNumber,
    required this.initialRarity,
    required this.initialOwned,
    required this.initialImagePath,
  });

  final String initialName;
  final String initialSet;
  final String initialNumber;
  final String initialRarity;
  final bool initialOwned;
  final String? initialImagePath;

  @override
  Widget build(BuildContext context) {
    return CardFormPage(
      initialName: initialName,
      initialSet: initialSet,
      initialNumber: initialNumber,
      initialRarity: initialRarity,
      initialOwned: initialOwned,
      initialImagePath: initialImagePath,
    );
  }
}
