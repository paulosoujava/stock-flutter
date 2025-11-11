import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/entities/reminder/reminder.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/entities/sale/sale_item.dart';
import 'package:stock/domain/entities/supplier/supplier.dart';
import 'package:window_manager/window_manager.dart';
import 'package:firebase_core/firebase_core.dart';

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

  // Se for uma plataforma desktop (Windows, macOS, ou Linux)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // É necessário aguardar a inicialização do gerenciador de janelas
    await windowManager.ensureInitialized();

    // Opções da janela que você quer definir
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),       // Define o tamanho inicial da janela
      minimumSize: Size(800, 600), // Define o tamanho mínimo permitido
      center: true,              // Centraliza a janela na tela
      title: 'Meu App de Estoque', // Define o título da janela
    );

    // Aguarda até que a janela esteja pronta para ser exibida e então aplica as opções
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        scaffoldBackgroundColor: Colors.grey[200], // Um fundo mais suave
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
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(SaleItemAdapter());
  Hive.registerAdapter(SupplierAdapter());
  Hive.registerAdapter(ReminderAdapter());
}
