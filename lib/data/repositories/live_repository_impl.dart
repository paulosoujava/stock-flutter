import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/repositories/ilive_repository.dart';
import 'package:uuid/uuid.dart';

class LiveRepositoryImpl implements ILiveRepository {
  static const _kLivesBox = 'lives';
  final Uuid _uuid = const Uuid();

  Future<Box<Live>> _openBox() async {
    if (!Hive.isBoxOpen('products')) {
      await Hive.openBox<Product>('products');
    }
    return Hive.openBox<Live>(_kLivesBox);
  }

  @override
  Future<List<Live>> getAllLives() async {
    final box = await _openBox();
    return box.values.toList();
  }

  @override
  Future<void> saveLive(Live live, List<Product> productsToLink) async {
    final liveBox = await _openBox();
    final productBox = Hive.box<Product>('products');

    if (!live.isInBox) {
      live.id = _uuid.v4();
    }

    final List<Product> validProductsFromBox = [];
    for (var product in productsToLink) {
      final productFromBox = productBox.get(product.key);
      if (productFromBox != null) {
        validProductsFromBox.add(productFromBox);
      }
    }

    live.products = HiveList(productBox, objects: validProductsFromBox);

    await liveBox.put(live.id, live);
  }

  @override
  Future<void> deleteLive(String liveId) async {
    final box = await _openBox();
    final live = box.get(liveId);
    if (live != null) {
      await live.delete();
    }
  }

  @override
  Future<Live?> getLiveById(String liveId) async {
    final box = await _openBox();
    return box.get(liveId);
  }
}
