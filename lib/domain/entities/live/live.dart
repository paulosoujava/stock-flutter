
import 'package:hive/hive.dart';
import 'package:stock/domain/entities/product/product.dart';

part 'live.g.dart';

@HiveType(typeId: 10)
enum LiveStatus {
  @HiveField(0)
  scheduled,
  @HiveField(1)
  live,
  @HiveField(2)
  finished,
}

@HiveType(typeId: 11)
class Live extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final DateTime? startDateTime;
  @HiveField(4)
  DateTime? endDateTime;
  @HiveField(5)
  late LiveStatus status;
  @HiveField(6)
  late HiveList<Product> products;

  // O construtor agora é o mais simples possível.
  Live({
    required this.title,
    this.description,
    this.startDateTime,
    this.endDateTime,
  }) {
    status = LiveStatus.scheduled;
    // O HiveList será inicializado pelo repositório.
  }
}
