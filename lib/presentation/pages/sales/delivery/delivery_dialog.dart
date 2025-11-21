// delivery_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/model/delivery.dart';
import '../../../../domain/entities/customer/customer.dart';

class DeliveryDialog extends StatefulWidget {
  final Customer? customer;
  final DeliveryData? deliveryToEdit;
  final Function(DeliveryData) onConfirm;
  final Function() onCancel;

  const DeliveryDialog({
    required this.onConfirm,
    required this.onCancel,
    this.customer,
    this.deliveryToEdit,
    super.key,
  });

  @override
  State<DeliveryDialog> createState() => _DeliveryDialogState();
}

class _DeliveryDialogState extends State<DeliveryDialog> {
  // Controllers
  final _customMethodController = TextEditingController();
  final _returnReasonController = TextEditingController();
  final _courierNameController = TextEditingController();
  final _courierNotesController = TextEditingController();
  final _customPaymentController = TextEditingController();

  // Valores selecionados
  String _selectedMethod = '';
  String _selectedStatus = '';
  String? _selectedAddress;
  String? _selectedPayment;
  DateTime? _deliveryDate;

  late List<String> _addresses;

  @override
  void initState() {
    super.initState();

    print("EDICAO = ${widget.deliveryToEdit}");
    // Monta lista de endereços
    _addresses = [];
    if (widget.customer != null) {
      if (widget.customer!.address.isNotEmpty) _addresses.add(widget.customer!.address);
      if (widget.customer!.address1?.isNotEmpty == true) _addresses.add(widget.customer!.address1!);
      if (widget.customer!.address2?.isNotEmpty == true) _addresses.add(widget.customer!.address2!);
    }

    // Valores padrão = vazio (para mostrar "Selecione...")
    _selectedMethod = '';
    _selectedStatus = '';
    _selectedPayment = null;
    _selectedAddress = null;

    // Só carrega valores se estiver EDITANDO
    if (widget.deliveryToEdit != null) {
      final d = widget.deliveryToEdit!;
      _selectedMethod = d.method;
      if (d.customMethod?.isNotEmpty == true) _selectedMethod = 'Outro';
      _customMethodController.text = d.customMethod ?? '';

      _selectedStatus = d.status;
      _deliveryDate = d.dispatchDate;

      _selectedPayment = d.paymentMethod;
      if (d.customPaymentMethod?.isNotEmpty == true) _selectedPayment = 'Outro';
      _customPaymentController.text = d.customPaymentMethod ?? '';

      _selectedAddress = d.addressId;

      _returnReasonController.text = d.returnReason ?? '';
      _courierNameController.text = d.courierName ?? '';
      _courierNotesController.text = d.courierNotes ?? '';
    }
  }

  @override
  void dispose() {
    _customMethodController.dispose();
    _returnReasonController.dispose();
    _courierNameController.dispose();
    _courierNotesController.dispose();
    _customPaymentController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deliveryDate ?? DateTime.now()),
    );
    if (pickedTime != null) {
      setState(() {
        _deliveryDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  bool get isStore => _selectedMethod == 'Loja';
  bool get isOutro => _selectedMethod == 'Outro';
  bool get isPaymentOutro => _selectedPayment == 'Outro';
  bool get isReturned => _selectedStatus == 'Retornou';
  bool get showDateField => _selectedStatus == 'Entregue' || _deliveryDate != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Text(
            widget.deliveryToEdit == null ? 'Nova Entrega' : 'Editar Entrega',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.92,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),

              // MÉTODO DE ENTREGA
              _buildDropdown(
                label: 'Método de Entrega',
                value: _selectedMethod.isEmpty ? null : _selectedMethod,
                items: ['Uber', 'Moto', 'Loja', 'Outro'],
                hint: 'Selecione o método de entrega',
                onChanged: (v) => setState(() => _selectedMethod = v ?? ''),
              ),
              if (isOutro) Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildTextField(_customMethodController, 'Ex: Drone, Bicicleta...'),
              ) else const SizedBox(height: 8),

              const SizedBox(height: 16),

              // FORMA DE PAGAMENTO
              _buildDropdown(
                label: 'Forma de Pagamento',
                value: _selectedPayment,
                items: ['Dinheiro', 'Cartão', 'Outro'],
                hint: 'Selecione a forma de pagamento',
                onChanged: (v) => setState(() => _selectedPayment = v),
              ),
              if (isPaymentOutro) Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildTextField(_customPaymentController, 'Ex: Pix, PicPay...'),
              ) else const SizedBox(height: 8),

              const SizedBox(height: 16),

              // ENDEREÇO (só se não for Loja)
              if (!isStore && _addresses.isNotEmpty)
                _buildDropdown(
                  label: 'Endereço de Entrega',
                  value: _selectedAddress, // null no novo → mostra hint, valor salvo na edição
                  items: _addresses,
                  hint: 'Selecione o endereço',
                  onChanged: (v) => setState(() => _selectedAddress = v),
                ),

              if (!isStore && _addresses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Nenhum endereço cadastrado', style: TextStyle(color: Colors.orange)),
                ),

              const SizedBox(height: 21),

              // STATUS
              _buildDropdown(
                label: 'Status da Entrega',
                value: _selectedStatus.isEmpty ? null : _selectedStatus,
                items: ['Pendente', 'Saiu para entrega', 'Entregue', 'Retornou'],
                hint: 'Selecione o status',
                onChanged: (v) => setState(() => _selectedStatus = v ?? ''),
              ),
              if (isReturned)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildTextField(_returnReasonController, 'Motivo do retorno', maxLines: 2),
                ),


              // DATA DA ENTREGA (aparece se status = Entregue ou já tiver data)
              if (showDateField)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: InkWell(
                    onTap: () => _selectDateTime(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: Colors.deepPurple),
                          const SizedBox(width: 12),
                          Text(
                            _deliveryDate == null
                                ? 'Toque para definir data e hora'
                                : DateFormat("dd/MM/yyyy 'às' HH:mm").format(_deliveryDate!),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          const Icon(Icons.edit_calendar, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),



              if (!isStore) ...[
                const SizedBox(height:8),
                _buildTextField(_courierNameController, 'Nome do Entregador'),
                const SizedBox(height: 16),
                _buildTextField(_courierNotesController, 'Observações, tais como: que recebeu o produto?', maxLines: 3),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('Cancelar')),
        ElevatedButton.icon(
          onPressed: () {
            if (_selectedMethod.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selecione o método de entrega')),
              );
              return;
            }
            if (!isStore && _selectedAddress == null && _addresses.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selecione o endereço de entrega')),
              );
              return;
            }
            if (_selectedStatus.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selecione o status da entrega')),
              );
              return;
            }

            final data = DeliveryData(
              method: _selectedMethod,
              customMethod: _selectedMethod == 'Outro' ? _customMethodController.text.trim() : null,
              addressId: isStore ? null : _selectedAddress,
              status: isStore ? 'Retirada na Loja' : _selectedStatus,
              dispatchDate: _selectedStatus == 'Entregue' ? (_deliveryDate ?? DateTime.now()) : _deliveryDate,
              returnReason: isReturned ? _returnReasonController.text.trim() : null,
              courierName: isStore ? null : _courierNameController.text.trim(),
              courierNotes: isStore ? null : _courierNotesController.text.trim(),
              paymentMethod: _selectedPayment,
              customPaymentMethod: _selectedPayment == 'Outro' ? _customPaymentController.text.trim() : null,
            );

            widget.onConfirm(data);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.check),
          label: Text(widget.deliveryToEdit == null ? 'Salvar' : 'Atualizar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: const TextStyle(color: Colors.grey)),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (v) => setState(() => onChanged(v)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}