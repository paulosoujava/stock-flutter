import 'package:injectable/injectable.dart';
// Importa a INTERFACE do repositório, não a implementação.
import 'package:stock/domain/repositories/icategory_repository.dart';

// 1. Anota a classe com @injectable para que o GetIt saiba como criá-la.
@injectable
class DeleteCategory {
  // 2. A classe depende da abstração (interface) do repositório.
  final ICategoryRepository _repository;

  // 3. O construtor recebe a dependência, que será injetada automaticamente.
  DeleteCategory(this._repository);

  // 4. O método 'call' permite que a classe seja usada como uma função.
  //    Ele recebe o ID da categoria a ser deletada e repassa a chamada
  //    para o método correspondente no repositório.
  Future<void> call(String categoryId) {
    return _repository.deleteCategory(categoryId);
  }
}
