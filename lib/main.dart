import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/entities/reminder/reminder.dart';
import 'package:stock/domain/entities/sale/delivery_info.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/entities/sale/sale_item.dart';
import 'package:stock/domain/entities/supplier/supplier.dart';
import 'package:stock/firebase_options.dart';
import 'package:stock/presentation/widgets/date_format_initializer.dart';
import 'package:uuid/uuid.dart';

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

  // ❗ REMOVER EM PRODUÇÃO
  //clearBD();

  //Injeção de dependências
  await configureDependencies();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      minimumSize: Size(850, 750),
      size: Size(1280, 720),        // tamanho inicial decente
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: 'Meu App de Estoque',
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();

      // AQUI É O SEGREDO NO MACOS:
      // Espera um frame antes de maximizar → evita o "Resize timed out"
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        await windowManager.maximize();
        // ou: await windowManager.setFullScreen(true); // se quiser tela cheia total
      });
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
  Hive.registerAdapter(DeliveryInfoAdapter());
  Hive.registerAdapter(LiveAdapter());
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

Future<void> clearBD()async {
  await Hive.deleteBoxFromDisk('customerBox');
  await Hive.deleteBoxFromDisk('liveBox');
  await Hive.deleteBoxFromDisk('saleBox');
  await Hive.deleteBoxFromDisk('productBox');
  //await fakeClients();
}
Future<void> fakeClients() async {
  final box = await Hive.openBox<Customer>('customerBox');

  // Limpa clientes antigos (comente se quiser manter)
  await box.clear();
  print('Box limpa. Inserindo 20 clientes...');

  final uuid = Uuid();

  final clientes = [
    Customer(
      id: uuid.v4(),
      name: "Ana Silva",
      cpf: "111.222.333-44",
      email: "ana.silva@gmail.com",
      phone: "(11) 98765-4321",
      whatsapp: "(11) 98765-4321",
      address: "Rua das Flores, 123 - Jardins",
      address1: "Apt 45 Bloco A",
      address2: "",
      instagram: "ana.silva",
      notes: "Cliente VIP - paga no PIX",
    ),
    Customer(
      id: uuid.v4(),
      name: "João Pedro",
      cpf: "222.333.444-55",
      email: "joao.pedro@hotmail.com",
      phone: "(11) 97654-3210",
      whatsapp: "(11) 97654-3210",
      address: "Av. Paulista, 1000",
      address1: "Conjunto 502",
      address2: "Bela Vista",
      instagram: "joaopedro.sp",
      notes: null,
    ),
    Customer(
      id: uuid.v4(),
      name: "Maria Oliveira",
      cpf: "333.444.555-66",
      email: "maria.oli@yahoo.com",
      phone: "(11) 96543-2109",
      whatsapp: "(11) 96543-2109",
      address: "Rua Augusta, 850",
      address1: "",
      address2: "Consolação",
      instagram: "mariaoli",
      notes: "Prefere entrega após 18h",
    ),
    Customer(
      id: uuid.v4(),
      name: "Carlos Santos",
      cpf: "444.555.666-77",
      email: "carlos.santos@outlook.com",
      phone: "(11) 95432-1098",
      whatsapp: "(11) 95432-1098",
      address: "Rua Oscar Freire, 400",
      address1: "Loja 12",
      address2: "",
      instagram: null,
      notes: "Entrega só sábado",
    ),
    Customer(
      id: uuid.v4(),
      name: "Fernanda Costa",
      cpf: "555.666.777-88",
      email: "fernanda.costa@gmail.com",
      phone: "(11) 94321-0987",
      whatsapp: "(11) 94321-0987",
      address: "Av. Brasil, 1200",
      address1: "Casa 3",
      address2: "Jardim América",
      instagram: "fernandacosta",
      notes: "Tem cachorro bravo",
    ),
    Customer(
      id: uuid.v4(),
      name: "Lucas Almeida",
      cpf: "666.777.888-99",
      email: "lucas.almeida@gmail.com",
      phone: "(11) 93210-9876",
      whatsapp: "(11) 93210-9876",
      address: "Rua Bela Cintra, 600",
      address1: "Cobertura",
      address2: "",
      instagram: "lucasalmeida",
      notes: null,
    ),
    Customer(
      id: uuid.v4(),
      name: "Juliana Lima",
      cpf: "777.888.999-00",
      email: "juliana.lima@icloud.com",
      phone: "(11) 92109-8765",
      whatsapp: "(11) 92109-8765",
      address: "Rua Haddock Lobo, 800",
      address1: "Apt 702",
      address2: "",
      instagram: "julimalima",
      notes: "Cliente fiel desde 2023",
    ),
    Customer(
      id: uuid.v4(),
      name: "Roberto Souza",
      cpf: "888.999.000-11",
      email: "roberto.souza@gmail.com",
      phone: "(11) 91098-7654",
      whatsapp: "(11) 91098-7654",
      address: "Av. Rebouças, 2000",
      address1: "",
      address2: "Pinheiros",
      instagram: null,
      notes: "Revendedor",
    ),
    Customer(
      id: uuid.v4(),
      name: "Camila Rocha",
      cpf: "999.000.111-22",
      email: "camila.rocha@gmail.com",
      phone: "(11) 90987-6543",
      whatsapp: "(11) 90987-6543",
      address: "Rua Consolação, 1500",
      address1: "Loja 5",
      address2: "",
      instagram: "camilinha.rocha",
      notes: "Revendedora oficial",
    ),
    Customer(
      id: uuid.v4(),
      name: "Paulo Henrique",
      cpf: "123.456.789-00",
      email: "paulo.h@gmail.com",
      phone: "(11) 99876-5432",
      whatsapp: "(11) 99876-5432",
      address: "Rua dos Pinheiros, 900",
      address1: "Apt 33",
      address2: "",
      instagram: "pauloh",
      notes: null,
    ),
    Customer(
      id: uuid.v4(),
      name: "Beatriz Mendes",
      cpf: "234.567.890-11",
      email: "bia.mendes@gmail.com",
      phone: "(11) 98765-4322",
      whatsapp: "(11) 98765-4322",
      address: "Rua Joaquim Floriano, 600",
      address1: "Sala 801",
      address2: "Itaim Bibi",
      instagram: "biamendes",
      notes: "Empresa - entrega comercial",
    ),
    Customer(
      id: uuid.v4(),
      name: "Gustavo Ramos",
      cpf: "345.678.901-22",
      email: "gustavo.ramos@empresa.com",
      phone: "(11) 97654-3221",
      whatsapp: "(11) 97654-3221",
      address: "Av. Faria Lima, 3500",
      address1: "12º andar",
      address2: "Itaim Bibi",
      instagram: null,
      notes: "Empresa - nota fiscal obrigatória",
    ),
    Customer(
      id: uuid.v4(),
      name: "Letícia Ferreira",
      cpf: "456.789.012-33",
      email: "leticiaf@gmail.com",
      phone: "(11) 96543-2110",
      whatsapp: "(11) 96543-2110",
      address: "Rua Teodoro Sampaio, 700",
      address1: "",
      address2: "Pinheiros",
      instagram: "leticiaferreira",
      notes: "Cliente fiel - presente de aniversário",
    ),
    Customer(
      id: uuid.v4(),
      name: "Marcos Vinicius",
      cpf: "567.890.123-44",
      email: "marcos.vini@gmail.com",
      phone: "(11) 95432-1009",
      whatsapp: "(11) 95432-1009",
      address: "Rua Henrique Schaumann, 500",
      address1: "Fundos",
      address2: "",
      instagram: null,
      notes: null,
    ),
    Customer(
      id: uuid.v4(),
      name: "Patrícia Nunes",
      cpf: "678.901.234-55",
      email: "patynunes@gmail.com",
      phone: "(11) 94321-0998",
      whatsapp: "(11) 94321-0998",
      address: "Av. Brigadeiro Faria Lima, 2000",
      address1: "Sala 150",
      address2: "",
      instagram: "patricianunes",
      notes: "Paga sempre no cartão",
    ),
    Customer(
      id: uuid.v4(),
      name: "Ricardo Martins",
      cpf: "789.012.345-66",
      email: "ricardo.martins@gmail.com",
      phone: "(11) 93210-9887",
      whatsapp: "(11) 93210-9887",
      address: "Rua Pamplona, 1200",
      address1: "Apt 55",
      address2: "Jardim Paulista",
      instagram: null,
      notes: "Motoqueiro parceiro",
    ),
    Customer(
      id: uuid.v4(),
      name: "Sabrina Castro",
      cpf: "890.123.456-77",
      email: "sabicastro@gmail.com",
      phone: "(11) 92109-8776",
      whatsapp: "(11) 92109-8776",
      address: "Rua Estados Unidos, 800",
      address1: "Casa 1",
      address2: "Jardins",
      instagram: "sabrina.castro",
      notes: "Revendedora top",
    ),
    Customer(
      id: uuid.v4(),
      name: "Thiago Barbosa",
      cpf: "901.234.567-88",
      email: "thiagobarbosa@gmail.com",
      phone: "(11) 91098-7665",
      whatsapp: "(11) 91098-7665",
      address: "Rua Girassol, 300",
      address1: "",
      address2: "Vila Madalena",
      instagram: "thibarbosa",
      notes: null,
    ),
    Customer(
      id: uuid.v4(),
      name: "Vanessa Duarte",
      cpf: "012.345.678-99",
      email: "vanessa.duarte@gmail.com",
      phone: "(11) 90987-6554",
      whatsapp: "(11) 90987-6554",
      address: "Rua Capote Valente, 400",
      address1: "Apt 22",
      address2: "",
      instagram: "vanessaduarte",
      notes: "Cliente desde o início",
    ),
    Customer(
      id: uuid.v4(),
      name: "Eduardo Pereira",
      cpf: "135.790.246-80",
      email: "edu.pereira@gmail.com",
      phone: "(11) 99887-7665",
      whatsapp: "(11) 99887-7665",
      address: "Rua Artur de Azevedo, 1000",
      address1: "",
      address2: "Pinheiros",
      instagram: "edupereira",
      notes: "Entrega rápida",
    ),
  ];

  await box.addAll(clientes);
  print('Pronto! ${clientes.length} clientes cadastrados com sucesso!');
  print('Você já pode abrir o app e testar perfil + entrega.');

  await box.close();
}
