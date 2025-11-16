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
}
