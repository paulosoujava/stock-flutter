// presentation/viewmodels/live/live_list_view_model.dart
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/usecases/live/create_live_use_case.dart';
import 'package:stock/domain/usecases/live/delete_live_use_case.dart';
import 'package:stock/domain/usecases/live/finish_live_use_case.dart';
import 'package:stock/domain/usecases/live/get_active_live_use_case.dart';
import 'package:stock/domain/usecases/live/start_live_use_case.dart';
import '../../../../domain/repositories/ilive_repository.dart';
import 'live_list_intent.dart';
import 'live_list_state.dart';

@lazySingleton
class LiveListViewModel {
  final CreateLiveUseCase _createLive;
  final StartLiveUseCase _startLive;
  final FinishLiveUseCase _finishLive;
  final DeleteLiveUseCase _deleteLive;
  final GetActiveLiveUseCase _getActiveLive;
  final ILiveRepository _repository;

  final _stateController = BehaviorSubject<LiveListState>();

  Stream<LiveListState> get state => _stateController.stream;

  LiveListViewModel(
      this._createLive,
      this._startLive,
      this._finishLive,
      this._deleteLive,
      this._getActiveLive,
      this._repository,
      ) {
    loadLives(); // carrega na criação
  }

  void handleIntent(LiveListIntent intent) async {
    if (intent is CreateLiveIntent) {
      await _createLive(
        title: intent.title,
        description: intent.description,
        scheduledDate: intent.scheduledDate,
        goalAmountCents: intent.goalAmountCents,
      );
      loadLives(); // atualiza lista
    } else if (intent is StartLiveIntent) {
      await _startLive(intent.liveId);
      loadLives();
    } else if (intent is FinishLiveIntent) {
      await _finishLive(intent.liveId);
      loadLives(); // AQUI É O QUE ESTAVA FALTANDO
    } else if (intent is DeleteLiveIntent) {
      await _deleteLive(intent.liveId);
      loadLives();
    }
  }

  void loading() async {
    _stateController.add(LiveListLoading());
    await Future.delayed(const Duration(seconds: 1));
    loadLives();
  }

  // Método público para recarregar de fora (vital!)
  void loadLives() async {
    _stateController.add(LiveListLoading());
    try {
      final lives = await _repository.getAllLives();
      final active = await _getActiveLive();
      _stateController.add(LiveListLoaded(lives, active));
    } catch (e) {
      _stateController.add(LiveListError(e.toString()));
    }
  }

  void dispose() {
    _stateController.close();
  }
}