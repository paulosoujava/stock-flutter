// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:uuid/uuid.dart' as _i706;

import '../../domain/repositories/icategory_repository.dart' as _i204;
import '../../domain/repositories/icustomer_repository.dart' as _i141;
import '../../domain/repositories/idelivery_repository.dart' as _i398;
import '../../domain/repositories/ilogin_repository.dart' as _i93;
import '../../domain/repositories/iproduct_repository.dart' as _i213;
import '../../domain/repositories/ireminder_repository.dart' as _i657;
import '../../domain/repositories/isale_repository.dart' as _i666;
import '../../domain/repositories/isupplier_repository.dart' as _i377;
import '../../domain/usecases/auth/get_current_user_use_case.dart' as _i439;
import '../../domain/usecases/auth/sign_in_use_case.dart' as _i561;
import '../../domain/usecases/auth/sign_out_use_case.dart' as _i137;
import '../../domain/usecases/categories/add_category.dart' as _i159;
import '../../domain/usecases/categories/delete_category.dart' as _i618;
import '../../domain/usecases/categories/get_categories.dart' as _i263;
import '../../domain/usecases/categories/update_category.dart' as _i339;
import '../../domain/usecases/customers/add_customer.dart' as _i798;
import '../../domain/usecases/customers/delete_customer.dart' as _i627;
import '../../domain/usecases/customers/get_customers.dart' as _i286;
import '../../domain/usecases/customers/update_customer.dart' as _i531;
import '../../domain/usecases/delivery/get_delivery_usecase.dart' as _i37;
import '../../domain/usecases/delivery/register_delivery_usecase.dart' as _i885;
import '../../domain/usecases/products/add_product.dart' as _i125;
import '../../domain/usecases/products/delete_product.dart' as _i403;
import '../../domain/usecases/products/get_all_products_use_case.dart' as _i237;
import '../../domain/usecases/products/get_product_count_by_category.dart'
    as _i811;
import '../../domain/usecases/products/get_products_by_category.dart' as _i887;
import '../../domain/usecases/products/update_product.dart' as _i421;
import '../../domain/usecases/reminder/add_reminder.dart' as _i487;
import '../../domain/usecases/reminder/delete_reminder.dart' as _i859;
import '../../domain/usecases/reminder/get_reminders.dart' as _i130;
import '../../domain/usecases/reminder/update_reminder.dart' as _i244;
import '../../domain/usecases/sales/get_all_sales_use_case.dart' as _i217;
import '../../domain/usecases/sales/get_sales_by_month_use_case.dart' as _i853;
import '../../domain/usecases/sales/save_sale_use_case.dart' as _i378;
import '../../domain/usecases/sales/update_sale_use_case.dart' as _i1051;
import '../../domain/usecases/supplier/add_supplier.dart' as _i773;
import '../../domain/usecases/supplier/delete_supplier.dart' as _i82;
import '../../domain/usecases/supplier/get_suppliers.dart' as _i504;
import '../../domain/usecases/supplier/update_supplier.dart' as _i699;
import '../../presentation/pages/categories/form/category_form_viewmodel.dart'
    as _i393;
import '../../presentation/pages/categories/list/category_list_viewmodel.dart'
    as _i706;
import '../../presentation/pages/customer/form/customer_form_viewmodel.dart'
    as _i580;
import '../../presentation/pages/customer/list/customer_list_viewmodel.dart'
    as _i282;
import '../../presentation/pages/home/home_view_model.dart' as _i222;
import '../../presentation/pages/login/login_viewmodel.dart' as _i447;
import '../../presentation/pages/products/form/product_form_viewmodel.dart'
    as _i689;
import '../../presentation/pages/products/list/categories/product_category_list_viewmodel.dart'
    as _i724;
import '../../presentation/pages/products/list/products/product_list_viewmodel.dart'
    as _i922;
import '../../presentation/pages/reminder/form/reminder_form_viewmodel.dart'
    as _i520;
import '../../presentation/pages/reminder/list/reminder_list_viewmodel.dart'
    as _i1053;
import '../../presentation/pages/sales/customer_selection/customer_selection_view_model.dart'
    as _i466;
import '../../presentation/pages/sales/report/sales_report_view_model.dart'
    as _i417;
import '../../presentation/pages/sales/sales_view_model.dart' as _i387;
import '../../presentation/pages/supplier/form/supplier_form_viewmodel.dart'
    as _i926;
import '../../presentation/pages/supplier/list/supplier_list_viewmodel.dart'
    as _i387;
import '../events/event_bus.dart' as _i557;
import 'app_module.dart' as _i460;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final appModule = _$AppModule();
  gh.lazySingleton<_i706.Uuid>(() => appModule.uuid);
  gh.lazySingleton<_i59.FirebaseAuth>(() => appModule.firebaseAuth);
  gh.lazySingleton<_i141.ICustomerRepository>(
      () => appModule.customerRepository);
  gh.lazySingleton<_i204.ICategoryRepository>(
      () => appModule.categoryRepository);
  gh.lazySingleton<_i213.IProductRepository>(() => appModule.productRepository);
  gh.lazySingleton<_i666.ISaleRepository>(() => appModule.saleRepository);
  gh.lazySingleton<_i377.ISupplierRepository>(
      () => appModule.supplierRepository);
  gh.lazySingleton<_i657.IReminderRepository>(
      () => appModule.reminderRepository);
  gh.lazySingleton<_i93.ILoginRepository>(() => appModule.loginRepository);
  gh.lazySingleton<_i398.IDeliveryRepository>(
      () => appModule.deliveryRepository);
  gh.lazySingleton<_i557.EventBus>(
    () => _i557.EventBus(),
    dispose: (i) => i.dispose(),
  );
  gh.factory<_i237.GetAllProductsUseCase>(
      () => _i237.GetAllProductsUseCase(gh<_i213.IProductRepository>()));
  gh.factory<_i421.UpdateProduct>(
      () => _i421.UpdateProduct(gh<_i213.IProductRepository>()));
  gh.factory<_i887.GetProductsByCategory>(
      () => _i887.GetProductsByCategory(gh<_i213.IProductRepository>()));
  gh.factory<_i403.DeleteProduct>(
      () => _i403.DeleteProduct(gh<_i213.IProductRepository>()));
  gh.factory<_i811.GetProductCountByCategory>(
      () => _i811.GetProductCountByCategory(gh<_i213.IProductRepository>()));
  gh.factory<_i125.AddProduct>(
      () => _i125.AddProduct(gh<_i213.IProductRepository>()));
  gh.factory<_i561.SignInUseCase>(
      () => _i561.SignInUseCase(gh<_i93.ILoginRepository>()));
  gh.factory<_i137.SignOutUseCase>(
      () => _i137.SignOutUseCase(gh<_i93.ILoginRepository>()));
  gh.factory<_i339.UpdateCategory>(
      () => _i339.UpdateCategory(gh<_i204.ICategoryRepository>()));
  gh.factory<_i263.GetCategories>(
      () => _i263.GetCategories(gh<_i204.ICategoryRepository>()));
  gh.factory<_i159.AddCategory>(
      () => _i159.AddCategory(gh<_i204.ICategoryRepository>()));
  gh.factory<_i618.DeleteCategory>(
      () => _i618.DeleteCategory(gh<_i204.ICategoryRepository>()));
  gh.factory<_i885.RegisterDeliveryUseCase>(
      () => _i885.RegisterDeliveryUseCase(gh<_i398.IDeliveryRepository>()));
  gh.factory<_i37.GetDeliveryUseCase>(
      () => _i37.GetDeliveryUseCase(gh<_i398.IDeliveryRepository>()));
  gh.factory<_i504.GetSuppliers>(
      () => _i504.GetSuppliers(gh<_i377.ISupplierRepository>()));
  gh.factory<_i699.UpdateSupplier>(
      () => _i699.UpdateSupplier(gh<_i377.ISupplierRepository>()));
  gh.factory<_i773.AddSupplier>(
      () => _i773.AddSupplier(gh<_i377.ISupplierRepository>()));
  gh.factory<_i82.DeleteSupplier>(
      () => _i82.DeleteSupplier(gh<_i377.ISupplierRepository>()));
  gh.lazySingleton<_i387.SupplierListViewModel>(
    () => _i387.SupplierListViewModel(
      gh<_i504.GetSuppliers>(),
      gh<_i82.DeleteSupplier>(),
    ),
    dispose: (i) => i.dispose(),
  );
  gh.factory<_i1051.UpdateSaleUseCase>(
      () => _i1051.UpdateSaleUseCase(gh<_i666.ISaleRepository>()));
  gh.factory<_i853.GetSalesByMonthUseCase>(
      () => _i853.GetSalesByMonthUseCase(gh<_i666.ISaleRepository>()));
  gh.factory<_i217.GetAllSalesUseCase>(
      () => _i217.GetAllSalesUseCase(gh<_i666.ISaleRepository>()));
  gh.factory<_i378.SaveSaleUseCase>(
      () => _i378.SaveSaleUseCase(gh<_i666.ISaleRepository>()));
  gh.factory<_i244.UpdateReminder>(
      () => _i244.UpdateReminder(gh<_i657.IReminderRepository>()));
  gh.factory<_i487.AddReminder>(
      () => _i487.AddReminder(gh<_i657.IReminderRepository>()));
  gh.factory<_i859.DeleteReminder>(
      () => _i859.DeleteReminder(gh<_i657.IReminderRepository>()));
  gh.factory<_i130.GetReminders>(
      () => _i130.GetReminders(gh<_i657.IReminderRepository>()));
  gh.factory<_i926.SupplierFormViewModel>(() => _i926.SupplierFormViewModel(
        gh<_i773.AddSupplier>(),
        gh<_i699.UpdateSupplier>(),
      ));
  gh.lazySingleton<_i1053.ReminderListViewModel>(
    () => _i1053.ReminderListViewModel(
      gh<_i130.GetReminders>(),
      gh<_i244.UpdateReminder>(),
      gh<_i859.DeleteReminder>(),
    ),
    dispose: (i) => i.dispose(),
  );
  gh.factory<_i286.GetCustomers>(
      () => _i286.GetCustomers(gh<_i141.ICustomerRepository>()));
  gh.factory<_i627.DeleteCustomer>(
      () => _i627.DeleteCustomer(gh<_i141.ICustomerRepository>()));
  gh.factory<_i798.AddCustomer>(
      () => _i798.AddCustomer(gh<_i141.ICustomerRepository>()));
  gh.factory<_i222.HomeViewModel>(() => _i222.HomeViewModel(
        gh<_i237.GetAllProductsUseCase>(),
        gh<_i263.GetCategories>(),
        gh<_i557.EventBus>(),
        gh<_i137.SignOutUseCase>(),
      ));
  gh.factory<_i531.UpdateCustomer>(
      () => _i531.UpdateCustomer(gh<_i141.ICustomerRepository>()));
  gh.factory<_i393.CategoryCreateViewModel>(() => _i393.CategoryCreateViewModel(
        gh<_i159.AddCategory>(),
        gh<_i339.UpdateCategory>(),
      ));
  gh.lazySingleton<_i282.CustomerListViewModel>(
    () => _i282.CustomerListViewModel(
      gh<_i286.GetCustomers>(),
      gh<_i627.DeleteCustomer>(),
    ),
    dispose: (i) => i.dispose(),
  );
  gh.factory<_i439.GetCurrentUserUseCase>(
      () => _i439.GetCurrentUserUseCase(gh<_i59.FirebaseAuth>()));
  gh.factory<_i447.LoginViewModel>(
      () => _i447.LoginViewModel(gh<_i561.SignInUseCase>()));
  gh.lazySingleton<_i466.CustomerSelectionViewModel>(
    () => _i466.CustomerSelectionViewModel(gh<_i286.GetCustomers>()),
    dispose: (i) => i.dispose(),
  );
  gh.factory<_i922.ProductListViewModel>(() => _i922.ProductListViewModel(
        gh<_i887.GetProductsByCategory>(),
        gh<_i403.DeleteProduct>(),
      ));
  gh.factory<_i689.ProductFormViewModel>(() => _i689.ProductFormViewModel(
        gh<_i125.AddProduct>(),
        gh<_i421.UpdateProduct>(),
        gh<_i557.EventBus>(),
      ));
  gh.factory<_i706.CategoryListViewModel>(() => _i706.CategoryListViewModel(
        gh<_i263.GetCategories>(),
        gh<_i618.DeleteCategory>(),
        gh<_i811.GetProductCountByCategory>(),
      ));
  gh.factory<_i724.ProductCategoryListViewModel>(
      () => _i724.ProductCategoryListViewModel(
            gh<_i263.GetCategories>(),
            gh<_i811.GetProductCountByCategory>(),
            gh<_i557.EventBus>(),
          ));
  gh.factory<_i580.CustomerFormViewModel>(() => _i580.CustomerFormViewModel(
        gh<_i798.AddCustomer>(),
        gh<_i531.UpdateCustomer>(),
      ));
  gh.factory<_i520.ReminderFormViewModel>(() => _i520.ReminderFormViewModel(
        gh<_i487.AddReminder>(),
        gh<_i244.UpdateReminder>(),
        gh<_i439.GetCurrentUserUseCase>(),
      ));
  gh.lazySingleton<_i387.SalesViewModel>(
    () => _i387.SalesViewModel(
      gh<_i237.GetAllProductsUseCase>(),
      gh<_i378.SaveSaleUseCase>(),
      gh<_i421.UpdateProduct>(),
      gh<_i439.GetCurrentUserUseCase>(),
      gh<_i706.Uuid>(),
      gh<_i557.EventBus>(),
    ),
    dispose: (i) => i.dispose(),
  );
  gh.factory<_i417.SalesReportViewModel>(() => _i417.SalesReportViewModel(
        gh<_i217.GetAllSalesUseCase>(),
        gh<_i1051.UpdateSaleUseCase>(),
        gh<_i286.GetCustomers>(),
        gh<_i885.RegisterDeliveryUseCase>(),
        gh<_i37.GetDeliveryUseCase>(),
        gh<_i557.EventBus>(),
      ));
  return getIt;
}

class _$AppModule extends _i460.AppModule {}
