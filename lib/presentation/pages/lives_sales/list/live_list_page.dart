import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/presentation/pages/lives_sales/list/live_list_intent.dart';
import 'package:stock/presentation/pages/lives_sales/list/live_list_state.dart';
import 'package:stock/presentation/pages/lives_sales/list/live_list_viewmodel.dart';

/// A tela principal que lista todas as "Vendas em Live".
/// Agora é um StatefulWidget para gerir o ciclo de vida do ViewModel.
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
                // Navega para o formulário e, quando voltar, recarrega a lista.
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
      // 4. Use um StreamBuilder para ouvir os estados do ViewModel.
      body: StreamBuilder<LiveListState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          // Estado de Carregamento
          if (state is LiveListLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estado de Erro
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

          // Estado de Sucesso
          if (state is LiveListSuccessState) {
            if (state.lives.isEmpty) {
              return const Center(
                  child: Text('Nenhuma live encontrada. Crie uma nova!'));
            }
            // Constrói a lista de lives a partir dos dados recebidos.
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.lives.length,
              itemBuilder: (context, index) {
                final live = state.lives[index];
                return _LiveCard(live: live);
              },
            );
          }

          // Estado Inicial ou Nulo
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

/// Widget privado que representa o card de uma única live na lista.
/// Agora recebe a entidade `Live` completa.
class _LiveCard extends StatelessWidget {
  final Live live;

  const _LiveCard({required this.live});

  /// Retorna a cor e o texto correspondente ao status da live.
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
            // --- CABEÇALHO DO CARD ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    live.title, // Usa o título da entidade
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
                live.description!, // Usa a descrição da entidade
                style: const TextStyle(color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Divider(height: 24),

            // --- INFORMAÇÕES DE DATA E HORA ---
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                    'Início: ${live.startDateTime.day}/${live.startDateTime.month}/${live.startDateTime.year} às ${live.startDateTime.hour}:${live.startDateTime.minute.toString().padLeft(2, '0')}'),
              ],
            ),

            const Divider(height: 24),

            // --- DADOS DA LIVE (Vendas, Compradores) ---
            // (Estes dados ainda são mocados, serão preenchidos no futuro)
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

            // --- TÍTULO DA SEÇÃO DE COMPRADORES ---
            // (A lógica de compradores será adicionada no futuro)
            // Text(
            //   "Compradores da Live",
            //   style: Theme.of(context)
            //       .textTheme
            //       .titleMedium
            //       ?.copyWith(color: Colors.black54),
            // ),
            // const SizedBox(height: 8),
            // _buildBuyerKnown(context),
            // _buildBuyerUnknown(context),

            // --- BOTÃO DE AÇÃO "INICIAR LIVE" ---
            if (live.status == LiveStatus.scheduled)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
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
                    label: const Text('INICIAR LIVE'),
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
      ),
    );
  }
}

/// Widget auxiliar para os tiles de informação (Valor, Itens, Compradores).
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
