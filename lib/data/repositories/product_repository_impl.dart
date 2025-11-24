import 'package:hive/hive.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/repositories/iproduct_repository.dart';
import 'package:uuid/uuid.dart';

const String _kProductBox = 'productBox';

class ProductRepositoryImpl implements IProductRepository {
  final _uuid = const Uuid();
  Box<Product>? _cachedBox;

  Future<Box<Product>> _openBox() async {
    if (_cachedBox?.isOpen ?? false) return _cachedBox!;
    _cachedBox = await Hive.openBox<Product>(_kProductBox);
    return _cachedBox!;
  }

  @override
  Future<List<Product>> getProductsByCategoryId(String categoryId) async {
    final box = await _openBox();
    final products = box.values
        .where((p) => p.categoryId == categoryId)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return products;
  }

  @override
  Future<Product?> getProductsByCode(String code) async {
    final box = await _openBox();

    // Filtra os produtos pelo código e retorna o primeiro encontrado (ou null)
    final foundProducts = box.values
        .where((p) => p.codeOfProduct?.trim() == code.trim())
        .toList();

    if (foundProducts.isEmpty) {
      return null;
    }

    // Ordena por nome (opcional, se quiser o "melhor" resultado)
    foundProducts
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    // Retorna o primeiro (ou o "melhor" após ordenação)
    return foundProducts.first;
  }

  @override
  Future<void> addProduct(Product product) async {
    final box = await _openBox();
    final newProduct = product.copyWith(id: _uuid.v4());
    await box.put(newProduct.id, newProduct);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final box = await _openBox();
    await box.put(product.id, product);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    final box = await _openBox();
    await box.delete(productId);
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final box = await _openBox();
    final products = box.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return products;
  }
}
