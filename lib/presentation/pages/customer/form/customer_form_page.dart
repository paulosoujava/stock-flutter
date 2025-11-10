// lib/app/presentation/pages/customer_form/customer_form_page.dart
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/presentation/widgets/custom_text_form_field.dart';
import 'customer_form_intent.dart';
import 'customer_form_state.dart';
import 'customer_form_viewmodel.dart'; // Para gerar um ID aleatório

class CustomerCreatePage extends StatefulWidget {
  final Customer? customerToEdit;

  const CustomerCreatePage({super.key, this.customerToEdit});

  @override
  State<CustomerCreatePage> createState() => _CustomerCreatePageState();
}

class _CustomerCreatePageState extends State<CustomerCreatePage> {
  late final CustomerFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isWhatsAppSameAsPhone = false;

  bool get isEditing => widget.customerToEdit != null;

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _whatsappFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CustomerFormViewModel>();

    if (isEditing) {
      final customer = widget.customerToEdit!;
      _nameController.text = customer.name;
      _cpfController.text = _cpfFormatter.maskText(customer.cpf);
      _emailController.text = customer.email;
      _phoneController.text = _phoneFormatter.maskText(customer.phone);
      _whatsappController.text = _phoneFormatter.maskText(customer.whatsapp);
      _addressController.text = customer.address;
      _notesController.text = customer.notes;
      if (customer.phone.isNotEmpty && customer.phone == customer.whatsapp) {
        // Usa setState para atualizar o estado do checkbox e a UI.
        setState(() {
          _isWhatsAppSameAsPhone = true;
        });
      }
    }

    _phoneController.addListener(_updateWhatsAppField);

    _viewModel.state.listen((state) {
      if (!mounted) return;

      if (state is CustomerFormSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
              content: Text(isEditing
                  ? 'Cliente atualizado com sucesso!'
                  : 'Cliente salvo com sucesso!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Retorna 'true' para indicar sucesso
      } else if (state is CustomerFormErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
      }
    });
  }

  @override
  void dispose() {
    // Limpeza dos controladores
    _phoneController.removeListener(_updateWhatsAppField);
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _notesController.dispose();
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
      final cleanCpf = _cpfFormatter.getUnmaskedText();
      final cleanPhone = _phoneFormatter.getUnmaskedText();
      final cleanWhatsApp = _whatsappFormatter.getUnmaskedText();
      final customerData = Customer(
        id: isEditing ? widget.customerToEdit!.id : '',
        name: _nameController.text.trim(),
        cpf: cleanCpf,
        email: _emailController.text.trim(),
        phone: cleanPhone,
        whatsapp: _isWhatsAppSameAsPhone ? cleanPhone : cleanWhatsApp,
        address: _addressController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (isEditing) {
        _viewModel.handleIntent(UpdateCustomerIntent(customerData));
      } else {
        _viewModel.handleIntent(SaveCustomerIntent(customerData));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cliente' : 'Novo Cliente'),
      ),
      body: StreamBuilder<CustomerFormState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          if (snapshot.data is CustomerFormLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextFormField(
                    controller: _nameController,
                    labelText: 'Nome Completo',
                    icon: Icons.person,
                    validator: (value) => (value?.isEmpty ?? true)
                        ? 'O nome é obrigatório'
                        : null,
                  ),
                  // 5. Campo CPF com máscara
                  CustomTextFormField(
                    controller: _cpfController,
                    labelText: 'CPF',
                    icon: Icons.badge,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_cpfFormatter], // Aplica a máscara
                  ),
                  CustomTextFormField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  // 6. Campo Telefone com máscara
                  CustomTextFormField(
                    controller: _phoneController,
                    labelText: 'Telefone',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [_phoneFormatter], // Aplica a máscara
                  ),
                  // 7. Checkbox e campo WhatsApp
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
                  CustomTextFormField(
                    controller: _whatsappController,
                    labelText: 'WhatsApp',
                    icon: Icons.chat_bubble,
                    keyboardType: TextInputType.phone,
                    // Desabilita o campo se o checkbox estiver marcado
                    enabled: !_isWhatsAppSameAsPhone,
                    inputFormatters: [_phoneFormatter], // Aplica a máscara
                  ),
                  CustomTextFormField(
                    controller: _addressController,
                    labelText: 'Endereço',
                    icon: Icons.location_on,
                  ),
                  CustomTextFormField(
                    controller: _notesController,
                    labelText: 'Texto Livre',
                    icon: Icons.notes,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      // ...
                    ),
                    child: const Text('Salvar Cliente'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
