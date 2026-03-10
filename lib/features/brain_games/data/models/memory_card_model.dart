import 'package:flutter/material.dart';

class MemoryCard {
  final int id;
  final IconData icon;
  bool isFaceUp;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.icon,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}
