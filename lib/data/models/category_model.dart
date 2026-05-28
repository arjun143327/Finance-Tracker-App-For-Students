import 'package:flutter/material.dart';

final Map<int, IconData> _iconRegistry = {
  Icons.restaurant_rounded.codePoint: Icons.restaurant_rounded,
  Icons.directions_bus_rounded.codePoint: Icons.directions_bus_rounded,
  Icons.shopping_bag_rounded.codePoint: Icons.shopping_bag_rounded,
  Icons.receipt_long_rounded.codePoint: Icons.receipt_long_rounded,
  Icons.medical_services_rounded.codePoint: Icons.medical_services_rounded,
  Icons.school_rounded.codePoint: Icons.school_rounded,
  Icons.movie_rounded.codePoint: Icons.movie_rounded,
  Icons.category_rounded.codePoint: Icons.category_rounded,
};

class CategoryModel {
  final int? id;
  final String name;
  final IconData icon;
  final Color color;

  CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint.toString(),
      'color': color.toARGB32(),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      icon: _iconRegistry[int.parse(map['icon'] ?? '${Icons.category_rounded.codePoint}')] ?? Icons.category_rounded,
      color: Color(map['color'] as int? ?? Colors.blue.toARGB32()),
    );
  }
}
