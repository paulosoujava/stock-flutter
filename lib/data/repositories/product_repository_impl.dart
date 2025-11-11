import 'dart:math';
import 'package:hive/hive.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/repositories/iproduct_repository.dart';

const String _kProductBox = 'productBox';


class ProductRepositoryImpl implements IProductRepository {

  Future<Box<Product>> _openBox() async {
    return Hive.openBox<Product>(_kProductBox);
  }

  @override
  Future<List<Product>> getProductsByCategoryId(String categoryId) async {
    final box = await _openBox();
    final products = box.values
        .where((product) => product.categoryId == categoryId)
        .toList();

    products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return products;
  }

  @override
  Future<void> addProduct(Product product) async {
    final box = await _openBox();
    final newProduct = Product(
      id: Random().nextInt(999999).toString(),
      name: product.name,
      description: product.description,
      costPrice: product.costPrice,
      salePrice: product.salePrice,
      stockQuantity: product.stockQuantity,
      lowStockThreshold: product.lowStockThreshold,
      categoryId: product.categoryId,
    );
    await box.put(newProduct.id, newProduct);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final box = await _openBox();
    // O método 'put' do Hive serve tanto para adicionar quanto para atualizar.
    // Se a chave (product.id) já existe, ele sobrescreve o objeto.
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
    // box.values retorna um Iterable com todos os objetos na caixa.
    // .toList() converte para uma lista.
    final allProducts = box.values.toList();
    return allProducts;
  }

}
