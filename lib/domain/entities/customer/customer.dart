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

  @HiveField(9)
  final String address1;

  @HiveField(10)
  final String address2;

  Customer({
    required this.id,
    required this.name,
    required this.cpf,
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.address,
    required this.address1,
    required this.address2,
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
    String? address1,
    String? address2,
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
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      notes: notes ?? this.notes,
      instagram: instagram ?? this.instagram,
    );
  }
}
    