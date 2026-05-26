import 'package:flutter/material.dart';
import 'package:sweeper_settings/domain/entities/user_settings.dart';
import 'package:sweeper_theme/app_tokens.dart';

class BoardSizePicker extends StatelessWidget {
  const BoardSizePicker({
    super.key,
    required this.selectedSize,
    required this.onSelected,
  });

  final int selectedSize;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: UserSettings.availableGridSizes.map((size) {
        final selected = selectedSize == size;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: ChoiceChip(
            label: Text('${size}x$size'),
            selected: selected,
            onSelected: (_) => onSelected(size),
          ),
        );
      }).toList(),
    );
  }
}
