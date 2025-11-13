
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/presentation/widgets/url_launcher_utils.dart'; // <-- IMPORTANTE: Importar o seu utils

/// Enum para representar o status da live.
/// Colocado aqui para ser acessível por todos os widgets neste ficheiro.
enum LiveStatus { scheduled, live, finished }

/// A tela principal que lista todas as "Vendas em Live".
class LiveListPage extends StatelessWidget {
  const LiveListPage({super.key});

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
          textAlign: TextAlign.start,
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton.icon(
              onPressed: () {
                context.push(AppRoutes.liveForm);
              },
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text('NOVA LIVE', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                // Adiciona um padding para um visual melhor
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: 3, // Usaremos dados mocados (falsos) por enquanto
        itemBuilder: (context, index) {
          // Simula diferentes status para visualização
          final statuses = [
            LiveStatus.scheduled, // Primeira live estará agendada
            LiveStatus.live, // Segunda estará acontecendo
            LiveStatus.finished, // Terceira já finalizou
          ];
          return _LiveCard(status: statuses[index]);
        },
      ),
    );
  }
}

/// Widget privado que representa o card de uma única live na lista.
class _LiveCard extends StatelessWidget {
  final LiveStatus status;

  const _LiveCard({required this.status});

  /// Retorna a cor e o texto correspondente ao status da live.
  (Color, String) _getStatusStyle() {
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
    final (statusColor, statusText) = _getStatusStyle();

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
                const Flexible(
                  child: Text(
                    'Live de Lançamento - Coleção Verão',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 8),
            const Text(
              'Descrição curta da live sobre os novos produtos de verão que chegaram.',
              style: TextStyle(color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 24),

            // --- INFORMAÇÕES DE DATA E HORA ---
            const Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                SizedBox(width: 8),
                Text('Início: 20/11/2025 às 19:00'),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.watch_later_outlined, size: 14, color: Colors.grey),
                SizedBox(width: 8),
                Text('Fim: 20/11/2025 às 21:00'),
              ],
            ),
            const Divider(height: 24),

            // --- DADOS DA LIVE (Vendas, Compradores) ---
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoTile(
                    icon: Icons.monetization_on,
                    label: 'Valor Total',
                    value: 'R\$ 1.250,75'),
                _InfoTile(
                    icon: Icons.shopping_cart,
                    label: 'Itens Vendidos',
                    value: '35'),
                _InfoTile(
                    icon: Icons.people, label: 'Compradores', value: '12'),
              ],
            ),
            const SizedBox(height: 16),

            // --- TÍTULO DA SEÇÃO DE COMPRADORES ---
            Text(
              "Compradores da Live",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 8),

            // --- EXEMPLOS DE COMPRADORES ---
            _buildBuyerKnown(context), // Exemplo de cliente conhecido
            _buildBuyerUnknown(context), // Exemplo de cliente desconhecido

            // --- BOTÃO DE AÇÃO "INICIAR LIVE" ---
            if (status == LiveStatus.scheduled)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // ROTA 2: Navegar para a sessão da live
                      context.push(
                        GoRouter.of(context).namedLocation(
                          'liveSession',
                          pathParameters: {
                            'liveId': '123'
                          }, // O ID virá do seu modelo de dados
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

  /// Exemplo visual para um cliente que JÁ ESTÁ na sua base de dados.
  Widget _buildBuyerKnown(BuildContext context) {
    // Dados mocados para o exemplo
    const email = 'paulosoujava@gmail.com';
    const phone = '(48) 99629-7813';
    const address = 'Rua das Flores, 123, Centro, Florianópolis - SC';
    const notes = 'Cliente VIP, prefere embalagem para presente.';

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.person, color: Colors.blue),
        title: const Text(
          'Paulo Jorge', // Nome do cliente
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        subtitle: const Text('@paulo.jorge'), // @ do Instagram
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  icon: Icons.email,
                  text: email,
                  onTap: () => UrlLauncherUtils.launchEmail(context, email),
                ),
                _DetailRow(icon: Icons.badge, text: '123.456.789-00'), // CPF não é clicável
                _DetailRow(
                  icon: Icons.phone,
                  text: phone,
                  onTap: () => UrlLauncherUtils.launchPhone(context, phone),
                ),
                _DetailRow(
                  icon: Icons.chat_bubble,
                  text: '$phone (WhatsApp)',
                  onTap: () => UrlLauncherUtils.launchWhatsApp(context, phone),
                ),
                _DetailRow(
                  icon: Icons.location_on,
                  text: address,
                  onTap: () => UrlLauncherUtils.launchMap(context, address),
                ),
                _DetailRow(icon: Icons.note, text: notes), // Notas não são clicáveis
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navegar para a tela de edição do cliente
                      // Ex: context.push('/customers/edit/clientId');
                    },
                    child: const Text('Ver/Editar Cadastro'),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Exemplo visual para um comprador que NÃO ESTÁ na sua base de dados.
  Widget _buildBuyerUnknown(BuildContext context) {
    const instagramHandle = '@ana.dev';
    return Card(
      color: Colors.orange.shade50,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.person_add_alt_1, color: Colors.orange),
        title: const Text(
          'Comprador não cadastrado',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        subtitle: const Text(instagramHandle),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            // ROTA: Navegar para a tela de cadastro, passando o @
            context.push(
              '${AppRoutes.customerCreate}?instagram=$instagramHandle',
            );
          },
          child: const Text('Cadastrar'),
        ),
      ),
    );
  }
}

/// Widget auxiliar para as linhas de detalhes dentro do ExpansionTile,
/// agora com suporte para ação de clique.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap; // Ação de clique é opcional

  const _DetailRow({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isClickable = onTap != null;
    final Color textColor = isClickable ? Theme.of(context).primaryColor : Colors.black87;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, top: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  decoration: isClickable ? TextDecoration.underline : null,
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
            style:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
