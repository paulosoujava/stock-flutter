import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/model/delivery.dart';
import '../../../../domain/entities/customer/customer.dart';

class DeliveryDialog extends StatefulWidget {
  final Customer? customer;
  final DeliveryData? deliveryToEdit;
  final Function(DeliveryData) onConfirm;

  const DeliveryDialog({
    required this.onConfirm,
    this.customer,
    this.deliveryToEdit,
    super.key,
  });

  @override
  State<DeliveryDialog> createState() => _DeliveryDialogState();
}

class _DeliveryDialogState extends State<DeliveryDialog> {
  // Controllers for text fields
  final _customMethodController = TextEditingController();
  final _returnReasonController = TextEditingController();
  final _courierNameController = TextEditingController();
  final _courierNotesController = TextEditingController();
  final _customPaymentController = TextEditingController();

  // Selected values
  String _selectedMethod = 'Uber';
  String _selectedStatus = 'Pendente';
  String? _selectedAddress;
  String? _selectedPayment;
  DateTime? _dispatchDate;

  // Dynamic addresses from customer
  late List<String> _addresses;

  @override
  void initState() {
    super.initState();
    // Dynamic: Filter non-empty addresses
    _addresses = [];
    if (widget.customer != null) {
      if (widget.customer!.address.isNotEmpty) {
        _addresses.add(widget.customer!.address);
      }
      if (widget.customer!.address1 != null) {
        _addresses.add(widget.customer!.address1!);
      }
      if (widget.customer!.address2 != null) {
        _addresses.add(widget.customer!.address2!);
      }
    }
    if (_addresses.isNotEmpty) _selectedAddress = _addresses.first;
    final deliveryToEdit = widget.deliveryToEdit;

    if (deliveryToEdit != null) {
      _selectedMethod = deliveryToEdit.method;
      _selectedStatus = deliveryToEdit.status ?? 'Pendente'; // Segurança extra
      _selectedPayment = deliveryToEdit.paymentMethod;

      // Use o operador '??' para fornecer um valor padrão ('') se a propriedade for nula.
      _customMethodController.text = deliveryToEdit.customMethod ?? '';
      _returnReasonController.text = deliveryToEdit.returnReason ?? '';
      _courierNameController.text = deliveryToEdit.courierName ?? '';
      _courierNotesController.text = deliveryToEdit.courierNotes ?? '';
      _customPaymentController.text = deliveryToEdit.customPaymentMethod ?? '';

      _dispatchDate = deliveryToEdit.dispatchDate;
      _selectedAddress = deliveryToEdit.addressId;
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _customMethodController.dispose();
    _returnReasonController.dispose();
    _courierNameController.dispose();
    _courierNotesController.dispose();
    _customPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isStore = _selectedMethod == 'Loja';
    final bool isOutro = _selectedMethod == 'Outro';
    final bool isReturned = _selectedStatus == 'Retornou';
    final bool isDispatched = _selectedStatus == 'Saiu para entrega';
    final bool isPaymentOutro = _selectedPayment == 'Outro';

    return AlertDialog(
      title: const Text('Registrar Entrega'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Método de entrega
              DropdownButtonFormField<String>(
                initialValue: _selectedMethod,
                items: ['Uber', 'Moto', 'Loja', 'Outro']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedMethod = val!),
                decoration: const InputDecoration(labelText: 'Método de Entrega'),
              ),
              if (isOutro)
                TextFormField(
                  controller: _customMethodController,
                  decoration:
                      const InputDecoration(labelText: 'Tipo Personalizado'),
                ),

              DropdownButtonFormField<String>(
                initialValue: _selectedPayment,
                items: ['Dinheiro', 'Cartão', 'Outro']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedPayment = val),
                decoration:
                    const InputDecoration(labelText: 'Método de Pagamento'),
              ),
              if (isPaymentOutro)
                TextFormField(
                  controller: _customPaymentController,
                  decoration:
                      const InputDecoration(labelText: 'Método Personalizado'),
                ),

              // Endereços (dynamic)
              if (!isStore && _addresses.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: _selectedAddress,
                  items: _addresses
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedAddress = val),
                  decoration:
                      const InputDecoration(labelText: 'Endereço de Entrega'),
                ),
              if (!isStore && _addresses.isEmpty)
                const Text('Nenhum endereço disponível para este cliente.'),

              // Status
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                items: ['Pendente', 'Saiu para entrega', 'Entregue', 'Retornou']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
                decoration: const InputDecoration(labelText: 'Status da Entrega'),
              ),

              // Data de despacho
              if (isDispatched)
                ListTile(
                  title: Text(_dispatchDate == null
                      ? 'Selecionar Data'
                      : DateFormat('dd/MM/yyyy').format(_dispatchDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _dispatchDate = date);
                  },
                ),

              // Justificativa de retorno
              if (isReturned)
                TextFormField(
                  controller: _returnReasonController,
                  decoration:
                      const InputDecoration(labelText: 'Motivo do Retorno'),
                ),

              // Entregador e observações (if not Loja)
              if (!isStore) ...[
                TextFormField(
                  controller: _courierNameController,
                  decoration:
                      const InputDecoration(labelText: 'Nome do Entregador'),
                ),
                TextFormField(
                  controller: _courierNotesController,
                  decoration: const InputDecoration(labelText: 'Observações'),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            final data = DeliveryData(
              method: _selectedMethod,
              customMethod: isOutro ? _customMethodController.text : null,
              addressId: !isStore ? _selectedAddress : null,
              status: isStore ? 'Retirada na Loja' : _selectedStatus,
              dispatchDate: isDispatched ? _dispatchDate : null,
              returnReason: isReturned ? _returnReasonController.text : null,
              courierName: !isStore ? _courierNameController.text : null,
              courierNotes: !isStore ? _courierNotesController.text : null,
              paymentMethod: _selectedPayment,
              // New
              customPaymentMethod:
                  isPaymentOutro ? _customPaymentController.text : null, // New
            );
            widget.onConfirm(data);
          },
          child:  Text(
              widget.deliveryToEdit == null ? 'Registrar' : 'Atualizar',
          )
        ),
      ],
    );
  }
}
