import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
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
import 'package:stock/firebase_options.dart';
import 'package:stock/presentation/widgets/date_format_initializer.dart';

import 'package:window_manager/window_manager.dart';

import 'core/navigation/app_router.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 📅 INITIALIZA O LOCALE pt_BR
  await initializeDateFormattingBR();

  // 📦 Hive
  await Hive.initFlutter();

  // ❗ REMOVER EM PRODUÇÃO
   //await Hive.deleteBoxFromDisk('liveBox');
   //await Hive.deleteBoxFromDisk('liveSalesBox');

  _registerHiveAdapters();

  // 🧩 Injeção de dependências
  await configureDependencies();

  // 🖥️ Configuração de Janelas (Somente Desktop)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      //size: Size(1000, 850),
      minimumSize: Size(850, 650),
      center: true,
      title: '📦 Meu App de Estoque',
      titleBarStyle: TitleBarStyle.normal,
      backgroundColor: Color(0xFF1E1E1E),
      skipTaskbar: false,
      fullScreen: false,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setBrightness(Brightness.dark);
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gestão de Estoque',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
    );
  }
}

/// Registra todos os adapters do Hive.
/// Não precisa ser async.
Future<void> _registerHiveAdapters() async {
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(SaleItemAdapter());
  Hive.registerAdapter(SupplierAdapter());
  Hive.registerAdapter(ReminderAdapter());

}

