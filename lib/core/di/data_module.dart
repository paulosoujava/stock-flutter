// lib/app/data/di/data_module.dart

import 'package:injectable/injectable.dart';
import 'package:stock/data/repositories/category_repository_impl.dart';
import 'package:stock/data/repositories/customer_repository_impl.dart';
import 'package:stock/data/repositories/product_repository_impl.dart';
import 'package:stock/domain/repositories/icategory_repository.dart';
import 'package:stock/domain/repositories/icustomer_repository.dart';
import 'package:stock/domain/repositories/iproduct_repository.dart';



@module
abstract class DataModule {
  @lazySingleton
  ICustomerRepository get customerRepository => CustomerRepositoryImpl();

  @lazySingleton
  ICategoryRepository get categoryRepository => CategoryRepositoryImpl();

  @lazySingleton
  IProductRepository get productRepository => ProductRepositoryImpl();
}
