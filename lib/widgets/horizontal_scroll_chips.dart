// lib/widgets/horizontal_scroll_chips.dart
import 'package:flutter/material.dart';
import 'category_chip.dart';

class HorizontalScrollChips extends StatelessWidget {
  final List<String> items;
  final String selectedItem;
  final Function(String) onTap;

  const HorizontalScrollChips({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      child: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true, // Agar track scrollbar terlihat
        thickness: 8,
        radius: const Radius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(), // Agar selalu bisa di-scroll
          child: Row(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryChip(
                  label: item,
                  isSelected: selectedItem == item,
                  onTap: () => onTap(item),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}