// Adicione esta nova classe no final do seu arquivo
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../domain/entities/customer/customer.dart';
import '../../../../../domain/repositories/icustomer_repository.dart';

enum CustomerTier { none, bronze, silver, gold }

class SingleCustomerAvatar extends StatefulWidget {
  final Customer customer;

  const SingleCustomerAvatar({super.key, required this.customer});

  @override
  State<SingleCustomerAvatar> createState() => _SingleCustomerAvatarState();
}

class _SingleCustomerAvatarState extends State<SingleCustomerAvatar> {
  Future<Customer?>? _customerFuture;

  // Funções de estilo para determinar o tier, ícone e cor
  CustomerTier _getTier(String? notes) {
    final lowerCaseNotes = notes?.toLowerCase() ?? '';
    if (lowerCaseNotes.contains('ouro')) return CustomerTier.gold;
    if (lowerCaseNotes.contains('prata')) return CustomerTier.silver;
    if (lowerCaseNotes.contains('bronze')) return CustomerTier.bronze;
    return CustomerTier.none;
  }

  IconData _getTierIcon(CustomerTier tier) {
    switch (tier) {
      case CustomerTier.gold: return Icons.emoji_events;
      case CustomerTier.silver: return Icons.military_tech;
      case CustomerTier.bronze: return Icons.workspace_premium;
      default: return Icons.person;
    }
  }

  Color _getTierColor(CustomerTier tier) {
    switch (tier) {
      case CustomerTier.gold: return Colors.amber.shade700;
      case CustomerTier.silver: return Colors.blueGrey.shade500;
      case CustomerTier.bronze: return Colors.brown.shade500;
      default: return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    // Busca os dados completos do cliente para ter acesso aos 'notes'
    final customerRepo = getIt<ICustomerRepository>();
    _customerFuture = customerRepo.getCustomersByIdOrInstagram(
      widget.customer.id,
      widget.customer.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Customer?>(
      future: _customerFuture,
      builder: (context, snapshot) {
        // Enquanto os dados estão carregando, mostra um avatar com um loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            backgroundColor: Colors.deepPurple,
            radius: 18,
            child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          );
        }

        final fullCustomer = snapshot.data;
        // Verifica se o cliente está realmente cadastrado no banco de dados
        final isRegistered = (fullCustomer != null &&
            fullCustomer.id.isNotEmpty &&
            !fullCustomer.id.startsWith('temp_'));

        final tier = _getTier(fullCustomer?.notes);
        final isSpecialTier = tier != CustomerTier.none;

        final IconData mainIcon;
        final Color iconColor;

        if (isSpecialTier) {
          // Se for tier especial, usa ícone e cor do tier
          mainIcon = _getTierIcon(tier);
          iconColor = _getTierColor(tier);
        } else {
          // Senão, usa ícone e cor baseados no status de registro
          mainIcon = isRegistered ? Icons.person : Icons.person_add;
          iconColor = isRegistered ? Colors.green.shade700 : Colors.orange.shade700;
        }

        // Retorna o CircleAvatar final com o ícone e cor corretos
        return CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.15),
          radius: 18,
          child: Icon(mainIcon, size: 18, color: iconColor),
        );
      },
    );
  }
}
