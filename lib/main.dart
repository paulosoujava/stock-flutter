import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/pages/customer/list/customer_list_page.dart';

import 'core/navigation/app_router.dart';

Future<void> main() async {
  //  Garante que os bindings do Flutter estejam prontos.
  WidgetsFlutterBinding.ensureInitialized();

  //  Inicializa o Hive.
  await Hive.initFlutter();

  //  REGISTRA TODOS OS ADAPTADORES PRIMEIRO.
  //    Isso é crucial para que a injeção de dependência funcione.
  _registerHiveAdapters();

  //  AGORA, com o Hive e os adaptadores prontos, configura a injeção de dependência.
  await configureDependencies();

  //  Inicia o aplicativo.
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Gestão de Estoque',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100], // Um fundo mais suave
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
    );
  }
}


/// Função privada para registrar todos os adaptadores do Hive.
void _registerHiveAdapters() {
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(ProductAdapter());
}
