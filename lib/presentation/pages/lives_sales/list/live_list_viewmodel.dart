import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/core/events/event_bus.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/usecases/live/delete_live_use_case.dart';
import 'package:stock/domain/usecases/live/get_all_lives_use_case.dart';
import 'package:stock/domain/usecases/live/start_live_use_case.dart';
import 'package:stock/presentation/pages/lives_sales/list/live_list_intent.dart';
import 'package:stock/presentation/pages/lives_sales/list/live_list_state.dart';

@injectable
class LiveListViewModel {
  final GetAllLivesUseCase _getAllLivesUseCase;
  final DeleteLiveUseCase _deleteLiveUseCase;
  final StartLiveUseCase _startLiveUseCase;
  final EventBus _eventBus;

  final _stateSubject = BehaviorSubject<LiveListState>();

  Stream<LiveListState> get state => _stateSubject.stream;

  LiveListViewModel(
    this._getAllLivesUseCase,
    this._deleteLiveUseCase,
    this._eventBus,
    this._startLiveUseCase,
  );

  /// Ponto de entrada para qualquer ação vinda da View.
  void handleIntent(LiveListIntent intent) {
    if (intent is LoadLivesIntent) {
      _loadLives();
    } else if (intent is DeleteLiveIntent) {
      _deleteLive(intent.liveId);
    } else if (intent is StartLiveIntent) {
      _startLive(intent.live);
    }
  }


  Future<void> _loadLives() async {
    _stateSubject.add(LiveListLoadingState());
    try {
      final lives = await _getAllLivesUseCase();
      // Ordena as lives, por exemplo, por data de início mais recente.
      lives.sort((a, b) {
        // Se b não tem data, ele vai para o fim.
        if (b.startDateTime == null) return -1;
        // Se a não tem data, ele vai para o fim.
        if (a.startDateTime == null) return 1;
        // Se ambos têm data, compara normalmente.
        return b.startDateTime!.compareTo(a.startDateTime!);
      });
      _stateSubject.add(LiveListSuccessState(lives));
    } catch (e) {
      _stateSubject.add(LiveListErrorState('Falha ao carregar as lives: $e'));
    }
  }

  Future<void> _deleteLive(String liveId) async {
    try {
      await _deleteLiveUseCase(liveId);
      // Após deletar com sucesso, recarrega a lista para refletir a mudança.
      _loadLives();
      // E dispara um evento para notificar outras partes da aplicação (como a HomePage)
      _eventBus.fire(ListChangedEvent(Live));
    } catch (e) {
      // Em caso de erro ao deletar, emita um estado de erro.
      // A lista original não será alterada.
      _stateSubject.add(LiveListErrorState('Falha ao deletar a live: $e'));
    }
  }

  Future<void> _startLive(Live live) async {
    try {
      final lives = await _getAllLivesUseCase();
      if (lives.any((l) => l.status == LiveStatus.live && l.id != live.id)) {
        // AQUI ESTÁ A LÓGICA CORRETA: Disparar o evento
        _eventBus.fire(ShowAlertDialogEvent(
          title: 'Atenção',
          message: 'Já existe uma live em andamento. Finalize a live atual antes de iniciar uma nova.',
        ));
        return;
      }

      await _startLiveUseCase(live);
      _stateSubject.add(NavigateToLiveSessionState(live.id));
      _loadLives();

    } catch (e) {
      _stateSubject.add(LiveListErrorState('Falha ao iniciar a live: $e'));
    }
  }
  /// Fecha o StreamController para evitar memory leaks.
  void dispose() {
    _stateSubject.close();
  }
}
