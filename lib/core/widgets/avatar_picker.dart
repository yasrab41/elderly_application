import 'package:flutter/material.dart';
import '../models/avatar_options.dart';

class AvatarPicker extends StatelessWidget {
  final int selectedId;
  final ValueChanged<int> onSelected;
  final double size;

  const AvatarPicker({
    super.key,
    required this.selectedId,
    required this.onSelected,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: List.generate(avatarOptions.length, (index) {
        final option = avatarOptions[index];
        final isSelected = selectedId == index;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: option.color.withOpacity(isSelected ? 1 : 0.25),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: const Color(0xFF48352A), width: 3)
                  : null,
            ),
            child: Icon(option.icon,
                color: isSelected ? Colors.white : option.color,
                size: size * 0.5),
          ),
        );
      }),
    );
  }
}
