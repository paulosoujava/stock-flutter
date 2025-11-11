import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/presentation/widgets/LowStockInfo.dart';

class LowStockAlertCard extends StatelessWidget {
  final List<LowStockInfo> lowStockInfoList;

  const LowStockAlertCard({
    super.key,
    required this.lowStockInfoList,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use o tamanho da nova lista
    final int productCount = lowStockInfoList.length;

    return Card(
      elevation: 2,
      color: Colors.amber[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade300),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        leading:
            Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
        title: Text(
          '$productCount Produto(s) com Estoque Baixo',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.amber.shade900,
          ),
        ),
        subtitle: Text(
          'Toque para ver mais detalhes',
          style: theme.textTheme.bodySmall,
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: lowStockInfoList.map((info) {
          final product = info.product;
          final category = info.category;

          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(product.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Estoque: ${product.stockQuantity}. (Limite: ${product.lowStockThreshold})',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.deepPurple),
              tooltip: 'Editar Produto',
              onPressed: () async {
                context.push<bool>(
                  AppRoutes.productEdit,
                  extra: {
                    'product': product,
                    'category': category,
                  },
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
