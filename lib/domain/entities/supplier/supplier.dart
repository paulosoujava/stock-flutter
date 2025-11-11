import 'package:hive/hive.dart';

part 'supplier.g.dart';

@HiveType(typeId: 6) // Use um typeId que ainda não foi usado (ex:6)
class Supplier extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String observation; // Texto livre

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.observation,
  });

  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? observation,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      observation: observation ?? this.observation,
    );
  }
}
