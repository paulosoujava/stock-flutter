// lib/domain/entities/category.dart
import 'package:hive/hive.dart';

part 'category.g.dart'; // Será gerado pelo build_runner

@HiveType(typeId: 1) // O typeId DEVE ser único (Customer é 0, Category é 1)
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  Category({
    required this.id,
    required this.name,
  });
}
