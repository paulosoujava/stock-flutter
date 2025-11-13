import 'package:hive/hive.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'dart:math';

import 'package:stock/domain/repositories/icustomer_repository.dart';

// Nome da "caixa" (box) onde os clientes serão armazenados. Pense nisso como uma tabela.
const String _kCustomerBox = 'customerBox';

class CustomerRepositoryImpl implements ICustomerRepository {

  // Abre a caixa de clientes. Se não existir, será criada.
  Future<Box<Customer>> _openBox() async {
    // Abrimos a box e especificamos o tipo de objeto que ela armazena
    return await Hive.openBox<Customer>(_kCustomerBox);
  }

  @override
  Future<List<Customer>> getCustomers() async {
    final box = await _openBox();
    // .values retorna todos os objetos da caixa como um Iterable<Customer>
    final customers = box.values.toList();
    // Ordena a lista por nome antes de retorná-la
    customers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return customers;
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    final box = await _openBox();
    // O Hive usa um sistema de chave-valor. A chave DEVE ser uma String ou int.
    // Vamos usar o ID do cliente como chave.
    // É crucial garantir que o ID seja único.
    final newCustomer = Customer(
      id: Random().nextInt(999999).toString(), // Gerar um ID único
      name: customer.name,
      cpf: customer.cpf,
      email: customer.email,
      phone: customer.phone,
      whatsapp: customer.whatsapp,
      address: customer.address,
      notes: customer.notes,
      instagram: customer.instagram
    );
    await box.put(newCustomer.id, newCustomer);
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    final box = await _openBox();
    // Deleta o objeto associado à chave (que é o nosso customerId)
    await box.delete(customerId);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final box = await _openBox();
    // O método 'put' do Hive tanto adiciona quanto atualiza.
    // Se a chave (customer.id) já existe, ele sobrescreve o valor.
    await box.put(customer.id, customer);
  }

  // Opcional: um método para fechar a caixa quando não for mais necessária
  // Pode ser útil em testes ou ao fazer logout do usuário, por exemplo.
  Future<void> close() async {
    final box = await _openBox();
    await box.close();
  }
}
