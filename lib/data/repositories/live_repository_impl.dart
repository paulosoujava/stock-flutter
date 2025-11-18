// data/repositories/live_repository_impl.dart
import 'package:hive/hive.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/repositories/ilive_repository.dart';
import 'package:uuid/uuid.dart';

const String _kLiveBox = 'liveBox';

class LiveRepositoryImpl implements ILiveRepository {
  final _uuid = Uuid();
  Box<Live>? _cachedBox;

  Future<Box<Live>> _openBox() async {
    if (_cachedBox?.isOpen ?? false) return _cachedBox!;
    _cachedBox = await Hive.openBox<Live>(_kLiveBox);
    return _cachedBox!;
  }

  @override
  Future<List<Live>> getAllLives() async {
    final box = await _openBox();
    final lives = box.values.toList();
    lives.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    return lives;
  }

  @override
  Future<void> addLive(Live live) async {
    final box = await _openBox();
    final newLive = live.copyWith(id: _uuid.v4());
    await box.put(newLive.id, newLive);
  }

  @override
  Future<void> updateLive(Live live) async {
    final box = await _openBox();
    await box.put(live.id, live);
  }

  @override
  Future<void> deleteLive(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  @override
  Future<Live?> getActiveLive() async {
    final box = await _openBox();
    try {
      return box.values.firstWhere(
            (live) => live.startDate != null && live.endDate == null,
      );
    } catch (_) {
      return null; // Agora é válido porque a função retorna Future<Live?>
    }
  }

  // Método auxiliar para notificar mudanças (vamos usar no ViewModel)
  Future<void> notifyUpdate() async {
    // Hive não tem listeners nativos fáceis, mas podemos forçar refresh
    // Vamos usar apenas em updates críticos
  }
}