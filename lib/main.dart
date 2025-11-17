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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormattingBR();

  await Hive.initFlutter();

  // REGISTRE ADAPTERS
  _registerHiveAdapters();

  //Injeção de dependências
  await configureDependencies();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      minimumSize: Size(850, 650),
      center: true,
      title: 'Meu App de Estoque',
      titleBarStyle: TitleBarStyle.normal,
      backgroundColor: Color(0xFF1E1E1E),
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setBrightness(Brightness.dark);
    });
  }

  runApp(const MyApp());
}

void _registerHiveAdapters() {
  Hive.registerAdapter(SaleItemAdapter());
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SupplierAdapter());
  Hive.registerAdapter(ReminderAdapter());
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



