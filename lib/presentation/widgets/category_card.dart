import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:stock/domain/entities/category/category.dart';

// O widget agora se chama CategoryCard, como sugerido.
class CategoryCard extends StatelessWidget {
  final Category category;
  final int productCount;
  final VoidCallback onTap;
  final Widget? trailing; // Permite adicionar widgets no final (ex: PopupMenuButton)

  const CategoryCard({
    super.key,
    required this.category,
    required this.productCount,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: theme.primaryColor.withOpacity(0.05),
        splashColor: theme.primaryColor.withOpacity(0.1),
        child: Row(
          children: [
            // --- COLUNA 1: ÍCONE/BADGE COM FUNDO ---
            Container(
              width: 100,
              color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: badges.Badge(
                  badgeContent: Text(
                    productCount.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  position: badges.BadgePosition.topEnd(top: -12, end: -12),
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: theme.colorScheme.primary,
                  ),
                  child: Icon(
                    Icons.folder_open_outlined,
                    size: 40,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
            // --- COLUNA 2: TÍTULO E AÇÃO TRAILING ---
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 80),
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        category.name.toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
