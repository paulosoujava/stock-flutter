import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Este widget auxiliar encapsula a lógica de ícones e cores
// para cada status de entrega.
class DeliveryStatusChip extends StatelessWidget {
  final String status;
  final bool isCanceled;

  const DeliveryStatusChip({
    required this.status,
    this.isCanceled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos os estilos com base no status
    final (IconData icon, Color color) = _getStyleForStatus(status);

    final chipColor = isCanceled ? Colors.grey.shade500 : color;

    return Row(
      mainAxisSize: MainAxisSize.min, // Garante que o Row ocupe o mínimo de espaço
      children: [
        Icon(icon, size: 14, color: chipColor),
        const SizedBox(width: 4),
        Text(
          'Delivery: $status',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: chipColor,
            fontWeight: status == "Não registrado" ? FontWeight.normal : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Função auxiliar privada para retornar o ícone e a cor corretos
  (IconData, Color) _getStyleForStatus(String status) {
    switch (status) {
      case 'Pendente':
        return (Icons.pending_actions_outlined, Colors.orange.shade700);
      case 'Em trânsito':
        return (Icons.local_shipping_outlined, Colors.blue.shade700);
      case 'Entregue':
        return (Icons.check_circle_outline_rounded, Colors.green.shade700);
      case 'Retornou':
        return (Icons.assignment_return_outlined, Colors.red.shade700);
      default: // 'Não registrado' ou qualquer outro caso
        return (Icons.help_outline_rounded, Colors.grey.shade700);
    }
  }
}
