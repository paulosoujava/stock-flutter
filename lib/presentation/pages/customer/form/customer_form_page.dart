import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'customer_form_intent.dart';
import 'customer_form_state.dart';
import 'customer_form_viewmodel.dart';

class CustomerFormPage extends StatefulWidget {
  final Customer? customerToEdit;

  const CustomerFormPage({super.key, this.customerToEdit});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  // --- LÓGICA ORIGINAL 100% PRESERVADA ---
  late final CustomerFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressController1 = TextEditingController();
  final _addressController2 = TextEditingController();
  final _notesController = TextEditingController();
  final _instagramController = TextEditingController();

  bool _isWhatsAppSameAsPhone = false;

  bool get isEditing => widget.customerToEdit != null;

  final _cpfFormatter =
  MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final _phoneFormatter =
  MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  final _whatsappFormatter =
  MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CustomerFormViewModel>();

    if (isEditing) {
      _populateFieldsForEditing();
    }

    _phoneController.addListener(_updateWhatsAppField);
  }

  void _populateFieldsForEditing() {
    final customer = widget.customerToEdit!;
    _nameController.text = customer.name;
    _emailController.text = customer.email ?? '';
    _addressController.text = customer.address;
    _addressController1.text = customer.address1 ?? "";
    _addressController2.text = customer.address2 ?? "";
    _notesController.text = customer.notes ?? "";
    _instagramController.text = customer.instagram ?? "";
    _cpfController.value = _cpfFormatter.formatEditUpdate(
        TextEditingValue.empty, TextEditingValue(text: customer.cpf));
    _phoneController.value = _phoneFormatter.formatEditUpdate(
        TextEditingValue.empty, TextEditingValue(text: customer.phone));
    _whatsappController.value = _whatsappFormatter.formatEditUpdate(
        TextEditingValue.empty, TextEditingValue(text: customer.whatsapp));
    if (customer.phone.isNotEmpty && customer.phone == customer.whatsapp) {
      setState(() => _isWhatsAppSameAsPhone = true);
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_updateWhatsAppField);
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _addressController1.dispose();
    _addressController2.dispose();
    _notesController.dispose();
    _instagramController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _updateWhatsAppField() {
    if (_isWhatsAppSameAsPhone) {
      _whatsappController.text = _phoneController.text;
    }
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final address = _addressController.text.trim();
      final address1 = _addressController1.text.trim();
      final address2 = _addressController2.text.trim();
      final filledAddresses =
      [address, address1, address2].where((addr) => addr.isNotEmpty).toList();

      if (filledAddresses.toSet().length < filledAddresses.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Os campos de endereço não podem ter valores repetidos.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final customerData = Customer(
        id: isEditing ? widget.customerToEdit!.id : '',
        name: _nameController.text.trim(),
        cpf: _cpfFormatter.getUnmaskedText(),
        email: _emailController.text.trim(),
        phone: _phoneFormatter.getUnmaskedText(),
        whatsapp: _isWhatsAppSameAsPhone
            ? _phoneFormatter.getUnmaskedText()
            : _whatsappFormatter.getUnmaskedText(),
        address: address,
        address1: address1,
        address2: address2,
        notes: _notesController.text.trim(),
        instagram: _instagramController.text.trim(),
      );

      if (isEditing) {
        _viewModel.handleIntent(UpdateCustomerIntent(customerData));
      } else {
        _viewModel.handleIntent(SaveCustomerIntent(customerData));
      }
    }
  }
  // --- FIM DA LÓGICA ORIGINAL ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<CustomerFormState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                final state = snapshot.data;

                if (state is CustomerFormSuccessState) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing
                              ? 'Cliente atualizado com sucesso!'
                              : 'Cliente salvo com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.pop(true);
                    }
                  });
                }

                if (state is CustomerFormErrorState) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red),
                      );
                    }
                  });
                }

                if (state is CustomerFormLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: _buildFormFields(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Voltar',
          ),
          const SizedBox(width: 16),
          Text(
            isEditing ? 'Editar Cliente' : 'Novo Cliente',
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800]),
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            icon: const Icon(Icons.save, size: 20),
            label: Text(isEditing ? 'Atualizar' : 'Salvar'),
            onPressed: _saveForm,
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionTitle('Dados Pessoais'),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person)),
            validator: (v) =>
            (v?.isEmpty ?? true) ? 'O nome é obrigatório' : null,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cpfController,
                  decoration: const InputDecoration(
                      labelText: 'CPF',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge)),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cpfFormatter],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _instagramController,
                  decoration: const InputDecoration(
                      labelText: 'Instagram (sem @)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.alternate_email)),
                ),
              ),
            ],
          ),
          const Divider(height: 48),
          _buildSectionTitle('Contato'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Telefone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneFormatter],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'E-mail (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text("WhatsApp é o mesmo que o telefone"),
            value: _isWhatsAppSameAsPhone,
            onChanged: (bool? value) {
              setState(() {
                _isWhatsAppSameAsPhone = value ?? false;
                _updateWhatsAppField();
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (!_isWhatsAppSameAsPhone)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(
                    labelText: 'WhatsApp',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.chat_bubble)),
                keyboardType: TextInputType.phone,
                inputFormatters: [_whatsappFormatter],
              ),
            ),
          const Divider(height: 48),
          _buildSectionTitle('Endereços'),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
                labelText: 'Endereço Principal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController1,
            decoration: const InputDecoration(
                labelText: 'Endereço 2 (Opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController2,
            decoration: const InputDecoration(
                labelText: 'Endereço 3 (Opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined)),
          ),
          const Divider(height: 48),
          _buildSectionTitle('Outras Informações'),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Observações e Nível (Ex: Cliente Ouro)',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}