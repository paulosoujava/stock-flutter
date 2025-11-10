import 'package:stock/domain/entities/category/category.dart';

/// Classe base para todas as intenções da tela de criação de categoria.
abstract class CategoryFormIntent {}

/// Intenção para salvar uma nova categoria.
/// Ela carrega os dados preenchidos no formulário.
class SaveCategoryIntent extends CategoryFormIntent {
  final Category category;
  SaveCategoryIntent(this.category);
}

class UpdateCategoryIntent extends CategoryFormIntent {
  final Category category;
  UpdateCategoryIntent(this.category);
}