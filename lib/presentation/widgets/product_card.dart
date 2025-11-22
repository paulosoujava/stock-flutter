import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock/domain/entities/product/product.dart';

/// Um widget de card reutilizável para exibir as informações de um produto.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A condição de estoque baixo que controla o estilo do card
    final bool isLowStock = product.stockQuantity <= product.lowStockThreshold;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isLowStock ? 4 : 2,
      shadowColor: isLowStock
          ? Colors.red.withOpacity(0.3)
          : Colors.black.withOpacity(0.1),
      // Muda a cor de fundo do card se o estoque estiver baixo
      color: isLowStock ? Colors.orange.shade50 : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Adiciona uma borda sutil de alerta
        side: isLowStock
            ? BorderSide(color: Colors.orange.shade200, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onEdit, // Ação principal ao clicar no card é editar
        hoverColor: theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Ícone e Título ---
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: theme.colorScheme.primary,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  color: theme.textTheme.titleLarge?.color,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "CÓD: ${product.codeOfProduct}",
                                style: GoogleFonts.robotoMono(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: theme.primaryColor.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // --- Menu de Ações ---
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Editar'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading:
                              Icon(Icons.delete_outline, color: Colors.red),
                          title: Text('Excluir',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(),
              const SizedBox(height: 8),
              // --- Descrição ---
              if (product.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left : 30.0, bottom: 12.0),
                  child: Text(
                    product.description,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              const Divider(),
              const SizedBox(height: 12),

              // --- Detalhes de Preço e Estoque ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailChip(
                    context,
                    icon: Icons.arrow_circle_up_outlined,
                    label: 'Venda',
                    value: 'R\$ ${product.salePrice.toStringAsFixed(2)}',
                    color: Colors.green.shade700,
                  ),
                  _buildDetailChip(
                    context,
                    icon: Icons.arrow_circle_down_outlined,
                    label: 'Custo',
                    value: 'R\$ ${product.costPrice.toStringAsFixed(2)}',
                    color: Colors.red.shade700,
                  ),
                  _buildDetailChip(
                    context,
                    icon: isLowStock
                        ? Icons.warning_amber_rounded
                        : Icons.inventory_2_outlined,
                    label: 'Estoque',
                    value: product.stockQuantity.toString(),
                    color:
                        isLowStock ? Colors.orange.shade900 : Colors.blueGrey,
                  ),
                ],
              ),

              // Adiciona o texto de alerta visível quando o estoque está baixo
              if (isLowStock)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange.shade900, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Estoque baixo, precisa de atenção!',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget auxiliar para criar os "chips" de detalhes.
  Widget _buildDetailChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
