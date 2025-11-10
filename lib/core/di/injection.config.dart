// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:stock/core/di/data_module.dart' as _i149;
import 'package:stock/domain/repositories/icategory_repository.dart' as _i836;
import 'package:stock/domain/repositories/icustomer_repository.dart' as _i64;
import 'package:stock/domain/usecases/categories/add_category.dart' as _i337;
import 'package:stock/domain/usecases/categories/delete_category.dart' as _i588;
import 'package:stock/domain/usecases/categories/get_categories.dart' as _i678;
import 'package:stock/domain/usecases/categories/update_category.dart' as _i460;
import 'package:stock/domain/usecases/customers/add_customer.dart' as _i139;
import 'package:stock/domain/usecases/customers/delete_customer.dart' as _i346;
import 'package:stock/domain/usecases/customers/get_customers.dart' as _i152;
import 'package:stock/domain/usecases/customers/update_customer.dart' as _i397;
import 'package:stock/presentation/pages/categories/form/category_form_viewmodel.dart'
    as _i260;
import 'package:stock/presentation/pages/categories/list/category_list_viewmodel.dart'
    as _i971;
import 'package:stock/presentation/pages/customer/form/customer_form_viewmodel.dart'
    as _i252;
import 'package:stock/presentation/pages/customer/list/customer_list_viewmodel.dart'
    as _i348;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final dataModule = _$DataModule();
    gh.lazySingleton<_i64.ICustomerRepository>(
        () => dataModule.customerRepository);
    gh.lazySingleton<_i836.ICategoryRepository>(
        () => dataModule.categoryRepository);
    gh.factory<_i460.UpdateCategory>(
        () => _i460.UpdateCategory(gh<_i836.ICategoryRepository>()));
    gh.factory<_i678.GetCategories>(
        () => _i678.GetCategories(gh<_i836.ICategoryRepository>()));
    gh.factory<_i337.AddCategory>(
        () => _i337.AddCategory(gh<_i836.ICategoryRepository>()));
    gh.factory<_i588.DeleteCategory>(
        () => _i588.DeleteCategory(gh<_i836.ICategoryRepository>()));
    gh.factory<_i971.CategoryListViewModel>(() => _i971.CategoryListViewModel(
          gh<_i678.GetCategories>(),
          gh<_i588.DeleteCategory>(),
        ));
    gh.factory<_i152.GetCustomers>(
        () => _i152.GetCustomers(gh<_i64.ICustomerRepository>()));
    gh.factory<_i346.DeleteCustomer>(
        () => _i346.DeleteCustomer(gh<_i64.ICustomerRepository>()));
    gh.factory<_i139.AddCustomer>(
        () => _i139.AddCustomer(gh<_i64.ICustomerRepository>()));
    gh.factory<_i397.UpdateCustomer>(
        () => _i397.UpdateCustomer(gh<_i64.ICustomerRepository>()));
    gh.factory<_i260.CategoryCreateViewModel>(
        () => _i260.CategoryCreateViewModel(
              gh<_i337.AddCategory>(),
              gh<_i460.UpdateCategory>(),
            ));
    gh.factory<_i348.CustomerListViewModel>(() => _i348.CustomerListViewModel(
          gh<_i152.GetCustomers>(),
          gh<_i346.DeleteCustomer>(),
        ));
    gh.factory<_i252.CustomerFormViewModel>(() => _i252.CustomerFormViewModel(
          gh<_i139.AddCustomer>(),
          gh<_i397.UpdateCustomer>(),
        ));
    return this;
  }
}

class _$DataModule extends _i149.DataModule {}
