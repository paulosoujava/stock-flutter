// Ficheiro: lib/presentation/pages/live_sales/session/live_session_page.dart
import 'package:flutter/material.dart';

class LiveSessionPage extends StatefulWidget {
  const LiveSessionPage({super.key});

  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage> {
  final _buyerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Em Live: Lançamento Verão'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Mostrar diálogo de confirmação para finalizar a live
              Navigator.of(context).pop();
            },
            child: const Text('FINALIZAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- PAINEL DE ENTRADA DE VENDAS ---
          _buildSalesInputPanel(context),

          const Divider(thickness: 2),

          // --- HISTÓRICO DE VENDAS DA LIVE ---
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vendas Recentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Total: R\$ 1.250,75', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: const [
                // Exemplo de card de venda
                _SaleHistoryCard(buyer: '@paulo.jorge', item: 'Camiseta Estampada Sol', price: 79.90, quantity: 1),
                _SaleHistoryCard(buyer: '@ana.dev', item: 'Shorts Jeans Verão', price: 120.00, quantity: 2),
                _SaleHistoryCard(buyer: '@paulo.jorge', item: 'Óculos de Sol Aviador', price: 250.00, quantity: 1, isKnownBuyer: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Painel superior para registrar uma nova venda
  Widget _buildSalesInputPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo para o @ do comprador
          TextField(
            controller: _buyerController,
            decoration: const InputDecoration(
              labelText: '@ do Comprador no Instagram',
              prefixIcon: Icon(Icons.alternate_email),
            ),
          ),
          const SizedBox(height: 8),

          // Aviso para comprador não cadastrado
          // TODO: A lógica de visibilidade será controlada pelo ViewModel
          const Card(
            color: Colors.orangeAccent,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Aviso: Cadastre este cliente ao finalizar a live.', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Seleção de produto
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Selecionar Produto'),
            items: const [
              // TODO: Carregar a lista de produtos da live
              DropdownMenuItem(value: 'prod1', child: Text('Camiseta Estampada Sol (Estoque: 34)')),
              DropdownMenuItem(value: 'prod2', child: Text('Shorts Jeans Verão (Estoque: 10)')),
              DropdownMenuItem(value: 'prod3', child: Text('Óculos de Sol Aviador (Estoque: 0)', style: TextStyle(color: Colors.red))),
            ],
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),

          // Seletor de quantidade e botão de adicionar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.remove_circle)),
                  const Text('1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () { /* TODO: Lógica de adicionar a venda e abater do estoque */ },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Adicionar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget privado para o card do histórico de vendas
class _SaleHistoryCard extends StatelessWidget {
  final String buyer;
  final String item;
  final double price;
  final int quantity;
  final bool isKnownBuyer;

  const _SaleHistoryCard({
    required this.buyer,
    required this.item,
    required this.price,
    required this.quantity,
    this.isKnownBuyer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(child: Icon(isKnownBuyer ? Icons.person : Icons.person_outline)),
        title: Text('$buyer comprou $quantity x $item'),
        subtitle: Text('Total: R\$ ${(price * quantity).toStringAsFixed(2)}'),
      ),
    );
  }
}
