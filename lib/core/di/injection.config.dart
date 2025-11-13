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
import 'package:stock/core/di/data_module.dart' as _i149;
import 'package:stock/core/events/event_bus.dart' as _i468;
import 'package:stock/data/repositories/login_repository_impl.dart' as _i700;
import 'package:stock/domain/repositories/icategory_repository.dart' as _i836;
import 'package:stock/domain/repositories/icustomer_repository.dart' as _i64;
import 'package:stock/domain/repositories/ilogin_repository.dart' as _i126;
import 'package:stock/domain/repositories/iproduct_repository.dart' as _i741;
import 'package:stock/domain/repositories/ireminder_repository.dart' as _i594;
import 'package:stock/domain/repositories/isale_repository.dart' as _i73;
import 'package:stock/domain/repositories/isupplier_repository.dart' as _i291;
import 'package:stock/domain/usecases/auth/get_current_user_use_case.dart'
    as _i723;
import 'package:stock/domain/usecases/auth/sign_in_use_case.dart' as _i517;
import 'package:stock/domain/usecases/auth/sign_out_use_case.dart' as _i149;
import 'package:stock/domain/usecases/categories/add_category.dart' as _i337;
import 'package:stock/domain/usecases/categories/delete_category.dart' as _i588;
import 'package:stock/domain/usecases/categories/get_all_sales_use_case.dart'
    as _i51;
import 'package:stock/domain/usecases/categories/get_categories.dart' as _i678;
import 'package:stock/domain/usecases/categories/update_category.dart' as _i460;
import 'package:stock/domain/usecases/customers/add_customer.dart' as _i139;
import 'package:stock/domain/usecases/customers/delete_customer.dart' as _i346;
import 'package:stock/domain/usecases/customers/get_customers.dart' as _i152;
import 'package:stock/domain/usecases/customers/update_customer.dart' as _i397;
import 'package:stock/domain/usecases/products/add_product.dart' as _i543;
import 'package:stock/domain/usecases/products/delete_product.dart' as _i847;
import 'package:stock/domain/usecases/products/get_all_products_use_case.dart'
    as _i281;
import 'package:stock/domain/usecases/products/get_product_count_by_category.dart'
    as _i228;
import 'package:stock/domain/usecases/products/get_products_by_category.dart'
    as _i614;
import 'package:stock/domain/usecases/products/update_product.dart' as _i185;
import 'package:stock/domain/usecases/reminder/add_reminder.dart' as _i419;
import 'package:stock/domain/usecases/reminder/delete_reminder.dart' as _i618;
import 'package:stock/domain/usecases/reminder/get_reminders.dart' as _i76;
import 'package:stock/domain/usecases/reminder/update_reminder.dart' as _i270;
import 'package:stock/domain/usecases/sales/get_sales_by_month_use_case.dart'
    as _i554;
import 'package:stock/domain/usecases/sales/save_sale_use_case.dart' as _i510;
import 'package:stock/domain/usecases/supplier/add_supplier.dart' as _i761;
import 'package:stock/domain/usecases/supplier/delete_supplier.dart' as _i838;
import 'package:stock/domain/usecases/supplier/get_suppliers.dart' as _i902;
import 'package:stock/domain/usecases/supplier/update_supplier.dart' as _i564;
import 'package:stock/presentation/pages/categories/form/category_form_viewmodel.dart'
    as _i851;
import 'package:stock/presentation/pages/categories/list/category_list_viewmodel.dart'
    as _i971;
import 'package:stock/presentation/pages/customer/form/customer_form_viewmodel.dart'
    as _i252;
import 'package:stock/presentation/pages/customer/list/customer_list_viewmodel.dart'
    as _i348;
import 'package:stock/presentation/pages/home/home_view_model.dart' as _i740;
import 'package:stock/presentation/pages/login/login_viewmodel.dart' as _i183;
import 'package:stock/presentation/pages/products/form/product_form_viewmodel.dart'
    as _i3;
import 'package:stock/presentation/pages/products/list/categories/product_category_list_viewmodel.dart'
    as _i425;
import 'package:stock/presentation/pages/products/list/products/product_list_viewmodel.dart'
    as _i336;
import 'package:stock/presentation/pages/reminder/form/reminder_form_viewmodel.dart'
    as _i132;
import 'package:stock/presentation/pages/reminder/list/reminder_list_viewmodel.dart'
    as _i861;
import 'package:stock/presentation/pages/sales/customer_selection/customer_selection_view_model.dart'
    as _i832;
import 'package:stock/presentation/pages/sales/report/sales_report_view_model.dart'
    as _i100;
import 'package:stock/presentation/pages/sales/sales_view_model.dart' as _i161;
import 'package:stock/presentation/pages/supplier/form/supplier_form_viewmodel.dart'
    as _i509;
import 'package:stock/presentation/pages/supplier/list/supplier_list_viewmodel.dart'
    as _i443;
import 'package:uuid/uuid.dart' as _i706;

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
    gh.lazySingleton<_i706.Uuid>(() => dataModule.uuid);
    gh.lazySingleton<_i59.FirebaseAuth>(() => dataModule.firebaseAuth);
    gh.lazySingleton<_i64.ICustomerRepository>(
        () => dataModule.customerRepository);
    gh.lazySingleton<_i836.ICategoryRepository>(
        () => dataModule.categoryRepository);
    gh.lazySingleton<_i741.IProductRepository>(
        () => dataModule.productRepository);
    gh.lazySingleton<_i73.ISaleRepository>(() => dataModule.saleRepository);
    gh.lazySingleton<_i291.ISupplierRepository>(
        () => dataModule.supplierRepository);
    gh.lazySingleton<_i594.IReminderRepository>(
        () => dataModule.reminderRepository);
    gh.lazySingleton<_i468.EventBus>(
      () => _i468.EventBus(),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i281.GetAllProductsUseCase>(
        () => _i281.GetAllProductsUseCase(gh<_i741.IProductRepository>()));
    gh.factory<_i185.UpdateProduct>(
        () => _i185.UpdateProduct(gh<_i741.IProductRepository>()));
    gh.factory<_i614.GetProductsByCategory>(
        () => _i614.GetProductsByCategory(gh<_i741.IProductRepository>()));
    gh.factory<_i847.DeleteProduct>(
        () => _i847.DeleteProduct(gh<_i741.IProductRepository>()));
    gh.factory<_i228.GetProductCountByCategory>(
        () => _i228.GetProductCountByCategory(gh<_i741.IProductRepository>()));
    gh.factory<_i543.AddProduct>(
        () => _i543.AddProduct(gh<_i741.IProductRepository>()));
    gh.factory<_i460.UpdateCategory>(
        () => _i460.UpdateCategory(gh<_i836.ICategoryRepository>()));
    gh.factory<_i678.GetCategories>(
        () => _i678.GetCategories(gh<_i836.ICategoryRepository>()));
    gh.factory<_i337.AddCategory>(
        () => _i337.AddCategory(gh<_i836.ICategoryRepository>()));
    gh.factory<_i588.DeleteCategory>(
        () => _i588.DeleteCategory(gh<_i836.ICategoryRepository>()));
    gh.factory<_i902.GetSuppliers>(
        () => _i902.GetSuppliers(gh<_i291.ISupplierRepository>()));
    gh.factory<_i564.UpdateSupplier>(
        () => _i564.UpdateSupplier(gh<_i291.ISupplierRepository>()));
    gh.factory<_i761.AddSupplier>(
        () => _i761.AddSupplier(gh<_i291.ISupplierRepository>()));
    gh.factory<_i838.DeleteSupplier>(
        () => _i838.DeleteSupplier(gh<_i291.ISupplierRepository>()));
    gh.lazySingleton<_i443.SupplierListViewModel>(
      () => _i443.SupplierListViewModel(
        gh<_i902.GetSuppliers>(),
        gh<_i838.DeleteSupplier>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i554.GetSalesByMonthUseCase>(
        () => _i554.GetSalesByMonthUseCase(gh<_i73.ISaleRepository>()));
    gh.factory<_i510.SaveSaleUseCase>(
        () => _i510.SaveSaleUseCase(gh<_i73.ISaleRepository>()));
    gh.factory<_i51.GetAllSalesUseCase>(
        () => _i51.GetAllSalesUseCase(gh<_i73.ISaleRepository>()));
    gh.factory<_i270.UpdateReminder>(
        () => _i270.UpdateReminder(gh<_i594.IReminderRepository>()));
    gh.factory<_i419.AddReminder>(
        () => _i419.AddReminder(gh<_i594.IReminderRepository>()));
    gh.factory<_i618.DeleteReminder>(
        () => _i618.DeleteReminder(gh<_i594.IReminderRepository>()));
    gh.factory<_i76.GetReminders>(
        () => _i76.GetReminders(gh<_i594.IReminderRepository>()));
    gh.factory<_i509.SupplierFormViewModel>(() => _i509.SupplierFormViewModel(
          gh<_i761.AddSupplier>(),
          gh<_i564.UpdateSupplier>(),
        ));
    gh.lazySingleton<_i861.ReminderListViewModel>(
      () => _i861.ReminderListViewModel(
        gh<_i76.GetReminders>(),
        gh<_i270.UpdateReminder>(),
        gh<_i618.DeleteReminder>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i126.ILoginRepository>(
        () => _i700.LoginRepositoryImpl(gh<_i59.FirebaseAuth>()));
    gh.lazySingleton<_i100.SalesReportViewModel>(
      () => _i100.SalesReportViewModel(gh<_i51.GetAllSalesUseCase>()),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i152.GetCustomers>(
        () => _i152.GetCustomers(gh<_i64.ICustomerRepository>()));
    gh.factory<_i346.DeleteCustomer>(
        () => _i346.DeleteCustomer(gh<_i64.ICustomerRepository>()));
    gh.factory<_i139.AddCustomer>(
        () => _i139.AddCustomer(gh<_i64.ICustomerRepository>()));
    gh.factory<_i397.UpdateCustomer>(
        () => _i397.UpdateCustomer(gh<_i64.ICustomerRepository>()));
    gh.factory<_i851.CategoryCreateViewModel>(
        () => _i851.CategoryCreateViewModel(
              gh<_i337.AddCategory>(),
              gh<_i460.UpdateCategory>(),
            ));
    gh.lazySingleton<_i348.CustomerListViewModel>(
      () => _i348.CustomerListViewModel(
        gh<_i152.GetCustomers>(),
        gh<_i346.DeleteCustomer>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i723.GetCurrentUserUseCase>(
        () => _i723.GetCurrentUserUseCase(gh<_i59.FirebaseAuth>()));
    gh.factory<_i425.ProductCategoryListViewModel>(
        () => _i425.ProductCategoryListViewModel(
              gh<_i678.GetCategories>(),
              gh<_i228.GetProductCountByCategory>(),
            ));
    gh.lazySingleton<_i832.CustomerSelectionViewModel>(
      () => _i832.CustomerSelectionViewModel(gh<_i152.GetCustomers>()),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i336.ProductListViewModel>(() => _i336.ProductListViewModel(
          gh<_i614.GetProductsByCategory>(),
          gh<_i847.DeleteProduct>(),
        ));
    gh.factory<_i3.ProductFormViewModel>(() => _i3.ProductFormViewModel(
          gh<_i543.AddProduct>(),
          gh<_i185.UpdateProduct>(),
          gh<_i468.EventBus>(),
        ));
    gh.lazySingleton<_i161.SalesViewModel>(
      () => _i161.SalesViewModel(
        gh<_i281.GetAllProductsUseCase>(),
        gh<_i510.SaveSaleUseCase>(),
        gh<_i185.UpdateProduct>(),
        gh<_i723.GetCurrentUserUseCase>(),
        gh<_i706.Uuid>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i517.SignInUseCase>(
        () => _i517.SignInUseCase(gh<_i126.ILoginRepository>()));
    gh.factory<_i149.SignOutUseCase>(
        () => _i149.SignOutUseCase(gh<_i126.ILoginRepository>()));
    gh.factory<_i971.CategoryListViewModel>(() => _i971.CategoryListViewModel(
          gh<_i678.GetCategories>(),
          gh<_i588.DeleteCategory>(),
          gh<_i228.GetProductCountByCategory>(),
        ));
    gh.factory<_i252.CustomerFormViewModel>(() => _i252.CustomerFormViewModel(
          gh<_i139.AddCustomer>(),
          gh<_i397.UpdateCustomer>(),
        ));
    gh.factory<_i132.ReminderFormViewModel>(() => _i132.ReminderFormViewModel(
          gh<_i419.AddReminder>(),
          gh<_i270.UpdateReminder>(),
          gh<_i723.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i740.HomeViewModel>(
      () => _i740.HomeViewModel(
        gh<_i281.GetAllProductsUseCase>(),
        gh<_i678.GetCategories>(),
        gh<_i468.EventBus>(),
        gh<_i149.SignOutUseCase>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i183.LoginViewModel>(
        () => _i183.LoginViewModel(gh<_i517.SignInUseCase>()));
    return this;
  }
}

class _$DataModule extends _i149.DataModule {}
