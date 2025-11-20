import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/repositories/icustomer_repository.dart';
import 'package:uuid/uuid.dart';

const String _kCustomerBox = 'customerBox';

class CustomerRepositoryImpl implements ICustomerRepository {
  final _uuid = const Uuid();
  Box<Customer>? _cachedBox;

  Future<Box<Customer>> _openBox() async {
    if (_cachedBox?.isOpen ?? false) return _cachedBox!;
    _cachedBox = await Hive.openBox<Customer>(_kCustomerBox);
    return _cachedBox!;
  }

  @override
  Future<Customer?> getCustomerByInstagram(String instagram) async {
    final box = await _openBox();
    final clean = instagram.trim().toLowerCase();

    try {
      return box.values.firstWhere(
        (c) => c.instagram?.trim().toLowerCase() == clean,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Customer>> getCustomers() async {
    final box = await _openBox();
    final customers = box.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return customers;
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    final box = await _openBox();
    final newCustomer = customer.copyWith(id: _uuid.v4());
    await box.put(newCustomer.id, newCustomer);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final box = await _openBox();
    await box.put(customer.id, customer);
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    final box = await _openBox();
    await box.delete(customerId);
  }

  Future<List<Customer>> getAllCustomers() async {
    final box = await _openBox();
    final customers = box.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return customers;
  }

  Future<void> close() async {
    final box = await _openBox();
    await box.close();
    _cachedBox = null;
  }

  @override
  Future<Customer?> getCustomersByIdOrInstagram(
      String id, String instagram) async {
    final box = await _openBox();

    //  Prioridade máxima: Tenta buscar pelo ID se ele não estiver vazio.
    //    Esta é a operação mais rápida.
    if (id.isNotEmpty) {
      final customerById = box.get(id);
      if (customerById != null) {
        // Se encontrou, retorna imediatamente.
        return customerById;
      }
    }

    //  Se não encontrou pelo ID ou se o ID estava vazio, tenta buscar pelo Instagram.
    //    Esta operação é mais lenta, pois varre todos os clientes.
    if (instagram.isNotEmpty) {
      final cleanInstagram = instagram
          .trim()
          .toLowerCase()
          .replaceFirst(RegExp(r'^@'), ''); // Remove o @ do início
      print("id: $id instagram: $instagram cleanInstagram: $cleanInstagram");
      final customer = box.values.firstWhereOrNull(
            (customer) => customer.instagram?.trim().toLowerCase() == cleanInstagram,
      );

      print("PEGO DO BANCO: $customer");
      return customer;
    }
    return null;
  }
}
