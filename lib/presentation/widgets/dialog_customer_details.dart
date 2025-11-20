import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock/presentation/widgets/url_launcher_utils.dart';

import '../../domain/entities/customer/customer.dart';

// Enum para representar o tier do cliente, para um código mais limpo
enum CustomerTier { none, bronze, silver, gold }

class CustomerDetailsDialog extends StatelessWidget {
  final Customer customer;

  const CustomerDetailsDialog({super.key, required this.customer});

  // --- FUNÇÕES DE ESTILO (Helpers) ---

  // Identifica o tier com base nas anotações
  CustomerTier _getTier(String? notes) {
    final lowerCaseNotes = notes?.toLowerCase() ?? '';
    if (lowerCaseNotes.contains('ouro')) return CustomerTier.gold;
    if (lowerCaseNotes.contains('prata')) return CustomerTier.silver;
    if (lowerCaseNotes.contains('bronze')) return CustomerTier.bronze;
    return CustomerTier.none;
  }

  // Retorna a cor principal para o tier
  Color _getTierColor(CustomerTier tier) {
    switch (tier) {
      case CustomerTier.gold:
        return Colors.amber.shade700;
      case CustomerTier.silver:
        return Colors.blueGrey.shade500;
      case CustomerTier.bronze:
        return Colors.brown.shade500;
      default:
      // Usa a cor primária do tema como padrão
        return Colors.grey;
    }
  }

  // Retorna o ícone para o tier
  IconData _getTierIcon(CustomerTier tier) {
    switch (tier) {
      case CustomerTier.gold:
        return Icons.emoji_events;
      case CustomerTier.silver:
        return Icons.military_tech;
      case CustomerTier.bronze:
        return Icons.workspace_premium;
      default:
        return Icons.person; // Ícone padrão
    }
  }
  String _getTierName(CustomerTier tier) {
    switch (tier) {
      case CustomerTier.gold:
        return 'Cliente Ouro';
      case CustomerTier.silver:
        return 'Cliente Prata';
      case CustomerTier.bronze:
        return 'Cliente Bronze';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = _getTier(customer.notes);
    final isSpecialTier = tier != CustomerTier.none;
    final tierColor = _getTierColor(tier);
    final tierIcon = _getTierIcon(tier);
    final tierName = _getTierName(tier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // --- AVATAR (lógica mantida) ---
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isSpecialTier
                        ? tierColor.withOpacity(0.15)
                        : theme.primaryColor.withOpacity(0.1),
                    child: isSpecialTier
                        ? Icon(tierIcon, color: tierColor, size: 30)
                        : Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- NOME DO CLIENTE MODIFICADO ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                customer.name.toUpperCase(), // Nome em maiúsculas
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isSpecialTier)
                              const SizedBox(width: 8),
                            if (isSpecialTier)
                              Icon(tierIcon, color: tierColor, size: 24, ),
                          ],
                        ),

                        // --- INFORMAÇÕES SECUNDÁRIAS (CPF, Instagram) ---
                        if (customer.instagram?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('@${customer.instagram}',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                          ),
                        if (customer.cpf.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text('CPF: ${customer.cpf}',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                          ),
                        if (isSpecialTier)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              tierName,
                              style: TextStyle(
                                fontSize: 13,
                                color: tierColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              // O restante do código continua o mesmo...
              if(customer.phone.isNotEmpty)
                _infoRow('Telefone', customer.phone, Icons.phone,
                    color: Colors.green),
              if(customer.whatsapp.isNotEmpty)
                _infoRow(
                  'WhatsApp',
                  customer.whatsapp,
                  Icons.message,
                  color: Colors.green,
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new, color: Colors.green),
                    onPressed: () =>
                        UrlLauncherUtils.launchWhatsApp(context, customer.whatsapp),
                    tooltip: 'Abrir WhatsApp',
                  ),
                ),
              if(customer.instagram?.isNotEmpty ?? false)
                _infoRow(
                  'Instagram',
                  '@${customer.instagram}',
                  Icons.alternate_email,
                  color: Colors.purple,
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new, color: Colors.purple),
                    onPressed: () =>
                        UrlLauncherUtils.launchInstagram(context, customer.instagram),
                    tooltip: 'Abrir no Instagram',
                  ),
                ),
              if(customer.address.isNotEmpty)
                _infoRow(
                  'Endereço',
                  customer.address,
                  Icons.location_on,
                  color: Colors.blue,
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: () =>
                        UrlLauncherUtils.launchMap(context, customer.address),
                    tooltip: 'Abrir no mapa',
                  ),
                ),
              if (customer.address1?.isNotEmpty ?? false)
                _infoRow(
                  'Endereço 2',
                  customer.address1!,
                  Icons.location_on,
                  color: Colors.blue,
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: () => UrlLauncherUtils.launchMap(
                        context, customer.address1!),
                    tooltip: 'Abrir no mapa',
                  ),
                ),
              if (customer.address2?.isNotEmpty ?? false)
                _infoRow(
                  'Endereço 3',
                  customer.address2!,
                  Icons.location_on,
                  color: Colors.blue,
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: () => UrlLauncherUtils.launchMap(
                        context, customer.address2!),
                    tooltip: 'Abrir no mapa',
                  ),
                ),
              _infoRow(
                  'Observações', customer.notes ?? 'Sem observações', Icons.note),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('FECHAR',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon,
      {Color? color, Widget? trailing}) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color ?? Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                    child: Text(value,
                        style: const TextStyle(color: Colors.black87))),
                if (trailing != null) SizedBox(height: 36, child: trailing),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
