import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject{
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
  final String? notes;

  @HiveField(8)
  final String? instagram;

  Customer({
    required this.id,
    required this.name,
    required this.cpf,
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.address,
     this.notes,
     this.instagram,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? cpf,
    String? email,
    String? phone,
    String? whatsapp,
    String? address,
    String? notes,
    String? instagram,
  }){
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      instagram: instagram ?? this.instagram,
    );
  }
}
    