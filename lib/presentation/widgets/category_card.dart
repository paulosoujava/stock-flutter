import 'package:flutter/material.dart';
import 'package:stock/domain/entities/category/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final int productCount;final VoidCallback? onTap;
  final Widget? actions;

  const CategoryCard({
    super.key,
    required this.category,
    required this.productCount,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Usando o shadowColor do tema para um sombreamento mais suave
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      // InkWell fornece o efeito visual de "splash" ao tocar, que o Card puro não tem.
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            children: [
              // Um ícone para dar mais apelo visual
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.category_outlined,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              // Expanded garante que o texto ocupe o espaço disponível
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nome da categoria com mais destaque
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Contagem de produtos com um estilo mais sutil
                    Text(
                      productCount == 1
                          ? '1 produto'
                          : '$productCount produtos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Ações (seta de navegação) no final
              if (actions != null) actions!,
            ],
          ),
        ),
      ),
    );
  }
}
