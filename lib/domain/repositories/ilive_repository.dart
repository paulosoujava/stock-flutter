// Ficheiro: lib/domain/repositories/live_repository.dart

import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/product/product.dart';

/// Define o contrato para operações de dados relacionadas às Lives.
/// Esta abstração permite trocar a fonte de dados (Hive, Firebase, API)
/// sem alterar a lógica de negócio (UseCases, ViewModels).
abstract class ILiveRepository {
  /// Retorna uma lista de todas as lives salvas.
  Future<List<Live>> getAllLives();

  /// Salva uma nova live ou atualiza uma existente.
  /// A implementação decidirá se é uma criação ou atualização
  /// com base na existência do ID da live.
  Future<void> saveLive(Live live, List<Product> productsToLink);

  /// Deleta uma live específica com base no seu ID.
  Future<void> deleteLive(String liveId);

  /// Busca uma única live pelo seu ID.
  Future<Live?> getLiveById(String liveId);
}
