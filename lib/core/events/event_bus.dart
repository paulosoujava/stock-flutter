import 'dart:async';
import 'package:injectable/injectable.dart';

/// Define a classe base para todos os eventos que podem ser enviados.
abstract class AppEvent {}

/// Evento específico para quando um produto for atualizado.
class ProductUpdatedEvent extends AppEvent {}// Você pode adicionar outros eventos no futuro:
// class CategoryUpdatedEvent extends AppEvent {}
// class CustomerUpdatedEvent extends AppEvent {}

/// Um evento genérico que pode ser usado para outras listas no futuro.
/// Ou um evento específico como `class LiveListChangedEvent {}`
class ListChangedEvent extends AppEvent{
  final Type entityType;
  ListChangedEvent(this.entityType);
  @override
  String toString() {
    return 'ListChangedEvent para a entidade: $entityType';
  }
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
