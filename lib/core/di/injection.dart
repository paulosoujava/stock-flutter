import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  asExtension: false,
  preferRelativeImports: true,
)
Future<void> configureDependencies() async => $initGetIt(getIt);