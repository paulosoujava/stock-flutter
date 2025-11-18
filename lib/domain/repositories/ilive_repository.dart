import '../entities/live/live.dart';

abstract class ILiveRepository {
  Future<List<Live>> getAllLives();
  Future<Live?> getActiveLive();
  Future<void> addLive(Live live);
  Future<void> updateLive(Live live);
  Future<void> deleteLive(String id);
}