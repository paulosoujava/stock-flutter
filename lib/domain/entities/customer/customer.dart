import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String cpf;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String phone;

  @HiveField(5)
  final String whatsapp;

  @HiveField(6)
  final String address;

  @HiveField(7)
  final String notes;

  @HiveField(8)
  final String instagram;

  Customer({
    required this.id,
    required this.name,
    required this.cpf,
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.address,
    required this.notes,
    required this.instagram,
  });
}
    