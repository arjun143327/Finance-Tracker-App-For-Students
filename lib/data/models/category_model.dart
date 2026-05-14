import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String name;
  final IconData icon;
  final Color color;

  CategoryModel({
    this.id,
    required this.name,
    this.icon = Icons.category_rounded,
    this.color = Colors.blue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint.toString(),
      'color': color.value,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      icon: IconData(int.parse(map['icon'] ?? '0xe148'), fontFamily: 'MaterialIcons'),
      color: Color(map['color'] ?? Colors.blue.value),
    );
  }
}
