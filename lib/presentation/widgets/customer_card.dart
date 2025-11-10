import 'package:flutter/material.dart';
import '../../domain/entities/customer/customer.dart';

class CustomerCard extends StatefulWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          _buildCardHeader(),
          if (_isExpanded) _buildCardDetails(),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      title: Text(
        widget.customer.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      trailing: IconButton(
        icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
        onPressed: _toggleExpanded,
      ),
      onTap: _toggleExpanded,
    );
  }

  Widget _buildCardDetails() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.person_outline, 'CPF', widget.customer.cpf),
          _buildDetailRow(Icons.email_outlined, 'Email', widget.customer.email),
          _buildDetailRow(Icons.phone_outlined, 'Telefone', widget.customer.phone),
          _buildDetailRow(Icons.chat_bubble_outline, 'WhatsApp', widget.customer.whatsapp),
          _buildDetailRow(Icons.location_on_outlined, 'Endereço', widget.customer.address),
          _buildDetailRow(Icons.notes_outlined, 'Observações', widget.customer.notes),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: Colors.grey[800])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
          onPressed: widget.onEdit,
          tooltip: 'Editar',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[700]),
          onPressed: widget.onDelete,
          tooltip: 'Deletar',
        ),
      ],
    );
  }
}
