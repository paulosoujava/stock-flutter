import 'package:flutter/material.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  static final _cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##');
  static final _phoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####');

  /// Abre o WhatsApp de forma otimizada para desktop e mobile.
  Future<void> _launchWhatsApp(String phoneNumber, BuildContext context) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappUrlApi = Uri.parse("https://wa.me/55$cleanPhone");

    try {
      if (await canLaunchUrl(whatsappUrlApi)) {
        // LaunchMode.externalApplication é a melhor opção multiplataforma.
        // No mobile, abre o app. No desktop, abre o navegador que então
        // tentará abrir o app desktop, que é o comportamento esperado.
        await launchUrl(whatsappUrlApi, mode: LaunchMode.externalApplication);
      } else {
        throw 'Não foi possível abrir o WhatsApp.';
      }
    } catch (e) {
      // Mostra um feedback claro para o usuário caso algo dê errado.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao abrir o WhatsApp: Verifique se está instalado.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            Icons.person_outline,
            size: 28,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          customer.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _phoneFormatter.maskText(customer.phone),
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Excluir', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0).copyWith(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.badge_outlined,
                  label: 'CPF',
                  value: _cpfFormatter.maskText(customer.cpf),
                ),
                _buildDetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: customer.email,
                ),
                // Passa o BuildContext para a função de clique
                _buildClickableDetailRow(
                  icon: Icons.chat_bubble_outline,
                  label: 'WhatsApp',
                  value: _phoneFormatter.maskText(customer.whatsapp),
                  onTap: () => _launchWhatsApp(customer.whatsapp, context),
                ),
                _buildDetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Endereço',
                  value: customer.address,
                ),
                _buildDetailRow(
                  icon: Icons.notes_outlined,
                  label: 'Notas',
                  value: customer.notes,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para linhas de detalhe NÃO clicáveis.
  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para linhas de detalhe CLICÁVEIS, como o WhatsApp.
  Widget _buildClickableDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.deepPurple), // Cor diferente para indicar ação
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple, // Cor para indicar que é clicável
                      decoration: TextDecoration.underline, // Sublinhado para reforçar
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
