import 'package:stock/domain/entities/live/live.dart';

abstract class LiveListState {}

class LiveListLoading extends LiveListState {}

class LiveListLoaded extends LiveListState {
  final List<Live> lives;
  final Live? activeLive;
  LiveListLoaded(this.lives, this.activeLive);
}

class LiveListError extends LiveListState {
  final String message;
  LiveListError(this.message);
}