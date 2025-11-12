// lib/app/data/di/data_module.dart


import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:stock/data/repositories/category_repository_impl.dart';
import 'package:stock/data/repositories/customer_repository_impl.dart';
import 'package:stock/data/repositories/login_repository_impl.dart';
import 'package:stock/data/repositories/product_repository_impl.dart';
import 'package:stock/data/repositories/reminder_repository_impl.dart';
import 'package:stock/data/repositories/sale_repository_impl.dart';
import 'package:stock/data/repositories/supplier_repository_impl.dart';
import 'package:stock/domain/repositories/icategory_repository.dart';
import 'package:stock/domain/repositories/icustomer_repository.dart';
import 'package:stock/domain/repositories/ilogin_repository.dart';
import 'package:stock/domain/repositories/iproduct_repository.dart';
import 'package:stock/domain/repositories/ireminder_repository.dart';
import 'package:stock/domain/repositories/isale_repository.dart';
import 'package:stock/domain/repositories/isupplier_repository.dart';
import 'package:uuid/uuid.dart';

@module
abstract class DataModule {
  @lazySingleton
  Uuid get uuid => const Uuid();

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  ICustomerRepository get customerRepository => CustomerRepositoryImpl();

  @lazySingleton
  ICategoryRepository get categoryRepository => CategoryRepositoryImpl();

  @lazySingleton
  IProductRepository get productRepository => ProductRepositoryImpl();

  @lazySingleton
  ISaleRepository get saleRepository => SaleRepositoryImpl();

  @lazySingleton
  ISupplierRepository get supplierRepository => SupplierRepositoryImpl();

  @lazySingleton
  IReminderRepository get reminderRepository => ReminderRepositoryImpl();


}


