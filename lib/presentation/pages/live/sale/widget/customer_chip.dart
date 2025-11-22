// lib/presentation/pages/live/sale/widgets/customer_chip.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/presentation/widgets/dialog_customer_details.dart';

import '../../../../../domain/entities/live/live.dart';
import '../../../../../domain/repositories/icustomer_repository.dart';


enum CustomerTier { none, bronze, silver, gold }

class CustomerChip extends StatefulWidget {
  final Map<String, dynamic> buyer;
  final Live live;

  const CustomerChip({super.key, required this.buyer, required this.live});

  @override
  State<CustomerChip> createState() => _CustomerChipState();
}

class _CustomerChipState extends State<CustomerChip> {
  Future<Customer?>? _customerFuture;

  @override
  void initState() {
    super.initState();
    _customerFuture = _fetchCustomerData();
  }

  Future<Customer?> _fetchCustomerData() {
    final name = widget.buyer['name'] as String;
    final id = widget.buyer['id'] as String;
    final customerRepo = getIt<ICustomerRepository>();
    return customerRepo.getCustomersByIdOrInstagram(id, name);
  }

  // --- Funções de Estilo ---
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
  Widget build(BuildContext context) {
    final status = widget.live.status;
    return FutureBuilder<Customer?>(
      future: _customerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Chip(
            label: SizedBox(
                width: 20, height: 10, child: LinearProgressIndicator()),
          );
        }

        final fullCustomer = snapshot.data;
        final name = widget.buyer['name'] as String;
        final isRegistered = (fullCustomer != null &&
            fullCustomer.id.isNotEmpty &&
            !fullCustomer.id.startsWith('temp_'));

        // --- LÓGICA DE ESTILO ---
        final tier = _getTier(fullCustomer?.notes);
        final isSpecialTier = tier != CustomerTier.none;

        // Ícone e cor para o tier especial
        final IconData tierIcon = isSpecialTier ? _getTierIcon(tier) : Icons.person;

        final IconData registrationIcon = isRegistered ? Icons.person : Icons.person_add;
        final Color registrationColor = isRegistered ? Colors.green.shade700 : Colors.orange.shade700;

        return GestureDetector(
          onTap: () {
            if (isRegistered && fullCustomer != null) {
              showDialog(
                  context: context,
                  builder: (dialogContext) =>
                      CustomerDetailsDialog(customer: fullCustomer));
            } else if( status == LiveStatus.finished) {
              // NAO CADASTRADO ABRE TELA DE EDICAO
              String raw = name.replaceAll(' (não cadastrado)', '').trim();
              String instagram = raw.startsWith('@') ? raw.substring(1) : raw;
              instagram = instagram.split(' ').first;

              final tempCustomer = Customer(
                id: '',
                name: raw.replaceAll('@', '').split(' ').first,
                instagram: instagram,
                cpf: '',
                email: '',
                phone: '',
                whatsapp: '',
                address: '',
                address1: null,
                address2: null,
                notes: null, // Notes é nulo para cliente temporário
              );
              context.push(AppRoutes.customerEdit, extra: tempCustomer);
            }
          },
          child: Chip(
            avatar: Icon(
              registrationIcon,
              size: 16,
              color: registrationColor,
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min, // Faz a Row ter o tamanho mínimo
              children: [
                Text(name, style: const TextStyle(fontSize: 12)),
                if (isSpecialTier) ...[
                  const SizedBox(width: 6),
                  Icon(
                    tierIcon,
                    size: 16,
                  color: _getTierColor(tier),
                  ),
                ],
              ],
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        );
      },
    );
  }


}
