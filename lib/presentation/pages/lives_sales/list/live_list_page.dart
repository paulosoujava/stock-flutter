import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/presentation/pages/lives_sales/list/live_list_intent.dart';
import 'package:stock/presentation/pages/lives_sales/list/live_list_state.dart';
import 'package:stock/presentation/pages/lives_sales/list/live_list_viewmodel.dart';

class LiveListPage extends StatefulWidget {
  const LiveListPage({super.key});

  @override
  State<LiveListPage> createState() => _LiveListPageState();
}

class _LiveListPageState extends State<LiveListPage> {
  late final LiveListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<LiveListViewModel>();
    _viewModel.handleIntent(LoadLivesIntent());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Vendas em Live',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: () async {
                await context.push(AppRoutes.liveForm);
                _viewModel.handleIntent(LoadLivesIntent());
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('NOVA LIVE'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<LiveListState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is LiveListLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LiveListErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is LiveListSuccessState) {
            if (state.lives.isEmpty) {
              return const Center(
                  child: Text('Nenhuma live encontrada. Crie uma nova!'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.lives.length,
              itemBuilder: (context, index) {
                final live = state.lives[index];
                return _LiveCard(live: live);
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _LiveCard extends StatelessWidget {
  final Live live;

  const _LiveCard({required this.live});

  (Color, String) _getStatusStyle(LiveStatus status) {
    switch (status) {
      case LiveStatus.live:
        return (Colors.red, 'EM LIVE');
      case LiveStatus.scheduled:
        return (Colors.blue, 'AGENDADA');
      case LiveStatus.finished:
        return (Colors.grey, 'FINALIZADA');
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String liveId) {
    final viewModel = getIt<LiveListViewModel>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: const Text(
              'Você está certo que deseja deletar esta live? Ao clicar em Sim não conseguiremos recuperar os dados.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Sim', style: TextStyle(color: Colors.red)),
              onPressed: () {
                viewModel.handleIntent(DeleteLiveIntent(liveId));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusText) = _getStatusStyle(live.status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    live.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                ),
              ],
            ),
            if (live.description != null && live.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                live.description!,
                style: const TextStyle(color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Divider(height: 24),
            if (live.startDateTime != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                        'Início: ${live.startDateTime!.day}/${live.startDateTime!.month}/${live.startDateTime!.year} às ${live.startDateTime!.hour}:${live.startDateTime!.minute.toString().padLeft(2, '0')}'),
                  ],
                ),
              ),
            if (live.endDateTime != null)
              Row(
                children: [
                  const Icon(Icons.watch_later_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                      'Fim: ${live.endDateTime!.day}/${live.endDateTime!.month}/${live.endDateTime!.year} às ${live.endDateTime!.hour}:${live.endDateTime!.minute.toString().padLeft(2, '0')}'),
                ],
              ),
            const Divider(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoTile(
                    icon: Icons.monetization_on,
                    label: 'Valor Total',
                    value: 'R\$ 0,00'),
                _InfoTile(
                    icon: Icons.shopping_cart,
                    label: 'Itens Vendidos',
                    value: '0'),
                _InfoTile(
                    icon: Icons.people, label: 'Compradores', value: '0'),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            if (live.status == LiveStatus.scheduled)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: 150,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, live.id);
                        },
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('DELETAR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: 150,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push(
                            GoRouter.of(context).namedLocation(
                              'liveSession',
                              pathParameters: {'liveId': live.id},
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_circle_fill),
                        label: const Text('INICIAR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
