import 'dart:async';
import 'package:injectable/injectable.dart';

/// Define a classe base para todos os eventos que podem ser enviados.
abstract class AppEvent {}

/// Evento específico para avisaar outas paginas para atualizarem
class ProductEvent extends AppEvent {}
class SalesEvent extends AppEvent {}
class LiveEvent extends AppEvent {}
class ListChangedEvent extends AppEvent {
  final Object entity;

  ListChangedEvent(this.entity);

  @override
  String toString() => 'ListChangedEvent: $entity';
}



@lazySingleton
class EventBus {
  // Usamos um StreamController.broadcast para permitir múltiplos ouvintes.
  final _controller = StreamController<AppEvent>.broadcast();

  /// Stream que as outras partes do app (como ViewModels) podem ouvir.
  Stream<AppEvent> get stream => _controller.stream;

  /// Método para disparar um novo evento.
  void fire(AppEvent event) {
    _controller.add(event);
  }

  /// Método para limpar o controller quando o app for fechado.
  @disposeMethod
  void dispose() {
    _controller.close();
  }
}
