// presentation/pages/live/sale/live_sale_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'live_sale_intent.dart';
import 'live_sale_state.dart';
import 'live_sale_view_model.dart';

class LiveSaleScreen extends StatefulWidget {
  final String liveId;

  const LiveSaleScreen({super.key, required this.liveId});

  @override
  State<LiveSaleScreen> createState() => _LiveSaleScreenState();
}

class _LiveSaleScreenState extends State<LiveSaleScreen> {
  late final LiveSaleViewModel _vm;
  late final ConfettiController _confetti;
  late final FocusNode _instagramFocusNode;
  late final TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    _instagramFocusNode = FocusNode();
    _vm = getIt<LiveSaleViewModel>()..add(LoadLiveIntent(widget.liveId));
    _confetti = ConfettiController(duration: const Duration(seconds: 6));
    _discountController = TextEditingController();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _instagramFocusNode.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LiveSaleState>(
      stream: _vm.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? LiveSaleLoading();

        if (state is LiveSaleLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (state is LiveSaleLoaded) {
          if (state.goalAchieved &&
              _confetti.state != ConfettiControllerState.playing) {
            _confetti.play();
          }

          final sessionTotal = state.orders.fold<double>(
              0,
              (sum, o) =>
                  sum + o.totalWithGlobalDiscount(state.globalDiscount));
          final totalFaturado =
              (state.live.achievedAmount / 100) + sessionTotal;

          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  }),
              title: Text(state.live.title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              backgroundColor: Colors.amberAccent,
              elevation: 1,
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.discount_outlined),
                      onPressed: () async {
                        final controller = TextEditingController(
                            text: state.globalDiscount.toString());
                        final result = await showDialog<int>(
                            context: context,
                            builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  title: Row(
                                    children: [
                                      const Icon(Icons.discount_outlined,
                                          color: Colors.deepPurple, size: 28),
                                      const SizedBox(width: 12),
                                      const Text('Desconto Global'),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    // Faz a coluna ter o tamanho mínimo necessário
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Este desconto será aplicado a TODOS os produtos durante a live.',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 24),
                                      TextField(
                                        controller: controller,
                                        keyboardType: TextInputType.number,
                                        // Garante que só números sejam digitados
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        autofocus: true,
                                        // Abre o teclado automaticamente
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.percent,
                                              color: Colors.grey),
                                          hintText: '0',
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide
                                                .none, // Sem borda visível
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actionsAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  // Alinha os botões
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      // Apenas fecha o diálogo
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton.icon(
                                      icon: const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.white),
                                      label: const Text('Aplicar Desconto',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .green, // Cor primária consistente
                                      ),
                                      onPressed: () {
                                        // Valida o valor antes de fechar
                                        final val =
                                            int.tryParse(controller.text) ?? 0;
                                        Navigator.pop(
                                            context, val.clamp(0, 100));
                                      },
                                    ),
                                  ],
                                ));
                        if (result != null) {
                          _vm.add(SetGlobalDiscountIntent(result));
                        }
                      },
                    ),
                    /*if (state.globalDiscount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12)),
                          constraints:
                              const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Text('${state.globalDiscount}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),*/
                  ],
                ),
                TextButton.icon(
                  onPressed: () =>
                      _finalizeWithSummary(state, sessionTotal, totalFaturado),
                  icon:
                      const Icon(Icons.stop_circle_outlined, color: Colors.red),
                  label: const Text('Finalizar',
                      style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Row(
              children: [
                // LADO ESQUERDO
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // META
                      Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Meta da Live',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(
                                state.currency
                                    .format(state.live.goalAmount / 100),
                                style: GoogleFonts.poppins(
                                    fontSize: 32, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value:
                                  totalFaturado / (state.live.goalAmount / 100),
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation(
                                  state.goalAchieved
                                      ? Colors.green
                                      : Colors.deepPurple),
                              minHeight: 10,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Faturado até agora',
                                    style: TextStyle(color: Colors.grey[600])),
                                Text(state.currency.format(totalFaturado),
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            if (state.globalDiscount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.red[300]!)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Desconto global de ${state.globalDiscount}% aplicado em todas as vendas',
                                        style: TextStyle(
                                            color: Colors.red[800],
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      ConfettiWidget(
                          confettiController: _confetti,
                          blastDirectionality: BlastDirectionality.explosive),

                      // GRID DE PRODUTOS - só aparece se NÃO tiver produto selecionado
                      if (state.selectedProduct == null)
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 1,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                            itemCount: state.products.length,
                            itemBuilder: (_, i) {
                              final p = state.products[i];
                              return InkWell(
                                onTap: () => _vm.add(SelectProductIntent(p)),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(p.name,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 8),
                                      Text(state.currency.format(p.salePrice),
                                          style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // CAMPO DE INSTAGRAM E LISTA DE CLIENTES - só aparece quando tem produto selecionado
                      if (state.selectedProduct != null) ...[
                        // Campo de Instagram
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                    controller: state.instagramController,
                                    focusNode: _instagramFocusNode,
                                    decoration: InputDecoration(
                                      labelText: '@instagram',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      prefixText: '@',
                                    ),
                                    onSubmitted: (_) {
                                      _vm.add(SearchInstagramIntent());
                                      _instagramFocusNode.requestFocus();
                                    }),
                              ),
                              const SizedBox(width: 12),
                              FloatingActionButton(
                                onPressed: () =>
                                    _vm.add(SearchInstagramIntent()),
                                backgroundColor: Colors.green,
                                tooltip: 'Adicionar ',
                                elevation: 2,
                                child:
                                    const Icon(Icons.add, color: Colors.white),
                              )
                              //ElevatedButton(onPressed: () => _vm.add(SearchInstagramIntent()), child: const Text('Adicionar')),
                            ],
                          ),
                        ),

                        // Lista de clientes (rola infinitamente)
                        Expanded(
                          child: state.currentCustomers.isEmpty
                              ? Center(
                                  child: Text('Adicione clientes acima',
                                      style:
                                          TextStyle(color: Colors.grey[600])))
                              : ListView.builder(
                                  itemCount: state.currentCustomers.length,
                                  itemBuilder: (_, i) {
                                    final c = state.currentCustomers[i];
                                    final isTemp = c.id.startsWith('temp_');
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 4),
                                      child: ListTile(
                                        leading: Icon(
                                            isTemp
                                                ? Icons.warning_amber
                                                : Icons.person,
                                            color: isTemp
                                                ? Colors.orange
                                                : Colors.green),
                                        title: Text(c.name),
                                        trailing: IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () => _vm.add(
                                                RemoveCurrentCustomerIntent(
                                                    i))),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],

                      // FOOTER FIXO - produto selecionado
                      if (state.selectedProduct != null)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(26),
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, -3)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Nome e preço do produto
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          state.selectedProduct!.name,
                                          style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          state.currency.format(
                                              state.selectedProduct!.salePrice),
                                          style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Campo de desconto
                                  if (state.globalDiscount == 0)
                                    SizedBox(
                                      width: 120,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: _discountController,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          hintText: 'Desc %',
                                          hintStyle: TextStyle(
                                              color: Colors.deepPurple
                                                  .withOpacity(0.7)),
                                          filled: true,
                                          fillColor:
                                              Colors.white.withOpacity(0.8),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10.0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  // REMOVEMOS O BOTÃO "X" DAQUI E DO SIZEDBOX ANTERIOR
                                  const SizedBox(width: 16),
                                  // Botão Adicionar ao Carrinho
                                  FloatingActionButton(
                                    onPressed: state.currentCustomers.isEmpty
                                        ? null
                                        : () {
                                            // 1. Lê o valor do desconto do controller
                                            final discountValue = int.tryParse(
                                                    _discountController.text) ??
                                                0;

                                            // 2. Envia a intent para definir o desconto
                                            _vm.add(SetIndividualDiscountIntent(
                                                discountValue));

                                            _vm.add(AddOrderIntent());
                                            _discountController.clear();
                                          },
                                    backgroundColor:
                                        state.currentCustomers.isEmpty
                                            ? Colors.grey
                                            : Colors.green,
                                    tooltip: 'Adicionar ao Carrinho',
                                    elevation: 2,
                                    child: const Icon(Icons.add_shopping_cart,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),

                            // 2. O BOTÃO "X" POSICIONADO FORA E ACIMA DO FOOTER
                            Positioned(
                              left: 16,
                              // Posição horizontal inicial
                              top: -20,
                              // Posição vertical para flutuar acima do footer
                              child: Tooltip(
                                message: 'Deseja trocar de produto?',
                                child: CircleAvatar(
                                  radius: 22, // Um pouco maior para se destacar
                                  backgroundColor: Colors.red[400],
                                  child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () {
                                        _discountController.clear();
                                        _vm.add(SelectProductIntent(null));
                                      }),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // DIVISOR
                Container(width: 1, color: Colors.grey[300]),

                // LADO DIREITO - PEDIDOS
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.production_quantity_limits_sharp,
                              color: Colors.grey[600],
                              size: 32,
                            ),
                            Text(
                                '${state.orders.length} pedido${state.orders.length == 1 ? '' : 's'}',
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                            /* Text(
                                'Total sessão: ${state.currency.format(sessionTotal)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700])),*/
                          ],
                        ),
                      ),
                      Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.orders.length,
                          itemBuilder: (_, i) {
                            final order = state.orders[i];
                            final totalDiscount =
                                order.discountPercent + state.globalDiscount;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.deepPurple,
                                        child: Text(
                                          order.customers.length.toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        order.product.name,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        tooltip: 'Remover Pedido',
                                        onPressed: () =>
                                            _vm.add(RemoveOrderIntent(i)),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Divider(
                                        color: Colors.grey[300],
                                        height: 1,
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 6.0,
                                        runSpacing: 4.0,
                                        children: order.customers
                                            .map((customer) => Chip(
                                                  avatar: CircleAvatar(
                                                    backgroundColor: Colors
                                                        .deepPurple.shade300,
                                                    child: Text(
                                                      customer.name.isNotEmpty
                                                          ? customer.name[0]
                                                              .toUpperCase()
                                                          : '?',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  label: Text(customer.name,
                                                      style: const TextStyle(
                                                          fontSize: 12)),
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                ))
                                            .toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      if (totalDiscount > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4.0, top: 4.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700]),
                                              children: [
                                                const WidgetSpan(
                                                    child: Icon(
                                                        Icons.sell_outlined,
                                                        size: 14,
                                                        color: Colors.red)),
                                                const WidgetSpan(
                                                    child: SizedBox(width: 4)),
                                                TextSpan(
                                                  text:
                                                      'Desconto: $totalDiscount%  ',
                                                  style: TextStyle(
                                                      color: Colors.red[700],
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const TextSpan(
                                                    text: '• Total: '),
                                                TextSpan(
                                                  text: state.currency.format(order
                                                      .totalWithGlobalDiscount(
                                                          state
                                                              .globalDiscount)),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const Scaffold(
            body: Center(child: Text('Erro ao carregar live')));
      },
    );
  }

  void _finalizeWithSummary(
      LiveSaleLoaded state, double sessionTotal, double totalFaturado) async {
    // Gera a lista de compradores únicos para evitar a repetição do toSet() no build
    final uniqueCustomers = state.orders.expand((o) => o.customers).toSet();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        // Título mais impactante com ícone
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('Resumo da Live'),
          ],
        ),
        content: SizedBox(
          width: 600, // Mantém a largura
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção de Totais e Meta
                _buildSummarySection(
                  icon: Icons.flag_outlined,
                  title: 'Meta',
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.black87),
                      children: [
                        const TextSpan(text: 'Faturado: '),
                        TextSpan(
                          text: state.currency.format(totalFaturado),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: state.goalAchieved
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' / ${state.currency.format(state.live.goalAmount / 100)}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 32),

                // Seção de Pedidos da Sessão
                _buildSummarySection(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Nesta Sessão',
                  child: Text(
                    '${state.orders.length} pedidos realizados, totalizando ${state.currency.format(sessionTotal)}',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Seção de Produtos Vendidos
                _buildSummarySection(
                  icon: Icons.sell_outlined,
                  title: 'Produtos Vendidos',
                  // Usando ListTile para melhor alinhamento
                  child: Column(
                    children: state.orders
                        .map((order) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: const Icon(Icons.arrow_right,
                                  color: Colors.deepPurple),
                              title: Text(
                                  '${order.product.name} (${order.customers.length}x)',
                                  style: GoogleFonts.poppins()),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Seção de Compradores
                _buildSummarySection(
                  icon: Icons.people_outline,
                  title: 'Compradores (${uniqueCustomers.length})',
                  // Usando Wrap para um layout mais flexível que quebra a linha
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: uniqueCustomers
                        .map((customer) => Chip(
                              avatar: CircleAvatar(
                                  backgroundColor: Colors.grey.shade700,
                                  child: Text(customer.name[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white))),
                              label: Text(customer.name),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          //TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Continuar Live', style: TextStyle(color: Colors.black))),
          ElevatedButton.icon(
            icon: const Icon(Icons.live_tv, color: Colors.white),
            label: const Text('Continuar Live',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.power_settings_new, color: Colors.white),
            label: const Text('Finalizar Live',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _vm.add(FinalizeLiveIntent());
    }
  }

// Widget auxiliar para evitar repetição de código e manter a consistência
  Widget _buildSummarySection(
      {required IconData icon, required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          // Leve indentação para o conteúdo
          child: child,
        ),
      ],
    );
  }
}
