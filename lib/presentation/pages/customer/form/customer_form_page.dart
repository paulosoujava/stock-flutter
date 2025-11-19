// lib/app/presentation/pages/customer_form/customer_form_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/presentation/widgets/custom_text_form_field.dart';
import '../../../../core/di/app_module.dart';
import '../../live/list/live_list_view_model.dart';
import 'customer_form_intent.dart';
import 'customer_form_state.dart';
import 'customer_form_viewmodel.dart'; // Para gerar um ID aleatório

class CustomerFormPage extends StatefulWidget {
  final Customer? customerToEdit;

  const CustomerFormPage({super.key, this.customerToEdit});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  late final CustomerFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
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
      _populateFieldsForEditing();
    }

    _phoneController.addListener(_updateWhatsAppField);

  /*  _viewModel.state.listen((state) {
      if (!mounted) return;

      if (state is CustomerFormSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ||
                    widget.customerToEdit?.id.startsWith('temp_') == true
                ? 'Cliente salvo com sucesso!'
                : 'Cliente atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      } else if (state is CustomerFormErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
      }
    });*/
  }

  void _populateFieldsForEditing() {
    final customer = widget.customerToEdit!;

    // Para campos sem máscara, a atribuição direta funciona.
    _nameController.text = customer.name;
    _emailController.text = customer.email;
    _addressController.text = customer.address;
    _addressController1.text = customer.address1 ?? "";
    _addressController2.text = customer.address2 ?? "";
    _notesController.text = customer.notes ?? "";
    _instagramController.text = customer.instagram ?? "";

    // Para campos COM máscara, use o método .formatEditUpdate() do formatador.
    // Isso atualiza o controlador e o estado interno do formatador, mantendo-os em sincronia.
    _cpfController.value = _cpfFormatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: customer.cpf),
    );
    _phoneController.value = _phoneFormatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: customer.phone),
    );
    _whatsappController.value = _whatsappFormatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: customer.whatsapp),
    );

    if (customer.phone.isNotEmpty && customer.phone == customer.whatsapp) {
      setState(() {
        _isWhatsAppSameAsPhone = true;
      });
    }
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
      // 1. Coleta os valores dos endereços
      final address = _addressController.text.trim();
      final address1 = _addressController1.text.trim();
      final address2 = _addressController2.text.trim();

      // 2. Cria uma lista apenas com os endereços que foram preenchidos
      final filledAddresses = [address, address1, address2]
          .where((addr) => addr.isNotEmpty)
          .toList();

      // 3. Verifica se há duplicatas na lista de endereços preenchidos
      //    Convertendo para um Set, os duplicados são removidos.
      //    Se o tamanho do Set for menor que o da lista, significa que havia duplicatas.
      if (filledAddresses.toSet().length < filledAddresses.length) {
        // 4. Se houver duplicatas, mostra um erro e interrompe a função
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Os campos de endereço não podem ter valores repetidos.'),
            backgroundColor: Colors.orange,
          ),
        );
        return; // Interrompe a execução do método _saveForm
      }

      // Se passou na validação de endereços, o código continua normalmente...
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
        address: address,
        // Usa a variável que já foi tratada com .trim()
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cliente' : 'Novo Cliente'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveForm,
        label: Text(isEditing ? 'Atualizar' : 'Salvar'),
        icon: const Icon(Icons.save),
      ),
      body: StreamBuilder<CustomerFormState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {

          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final state = snapshot.data;

              if (state is CustomerFormSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing ? 'Cliente atualizado com sucesso!' : 'Cliente salvo com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Verifica se ainda pode voltar antes de chamar o pop
                if (context.canPop()) {
                  context.pop(true);
                }
              } else if (state is CustomerFormErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            });
          }


          if (snapshot.data is CustomerFormLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
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
                      CustomTextFormField(
                        controller: _cpfController,
                        labelText: 'CPF',
                        icon: Icons.badge,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_cpfFormatter],
                      ),
                      CustomTextFormField(
                        controller: _emailController,
                        labelText: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      CustomTextFormField(
                        controller: _instagramController,
                        labelText: 'Instagram',
                        icon: Icons.alternate_email_rounded,
                      ),
                      CustomTextFormField(
                        controller: _phoneController,
                        labelText: 'Telefone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_phoneFormatter],
                      ),
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
                        enabled: !_isWhatsAppSameAsPhone,
                        inputFormatters: [_phoneFormatter],
                      ),
                      CustomTextFormField(
                        controller: _addressController,
                        labelText: 'Endereço',
                        icon: Icons.location_on,
                      ),
                      CustomTextFormField(
                        controller: _addressController1,
                        labelText: 'Endereço 2',
                        icon: Icons.location_on,
                      ),
                      CustomTextFormField(
                        controller: _addressController2,
                        labelText: 'Endereço 3',
                        icon: Icons.location_on,
                      ),
                      CustomTextFormField(
                        controller: _notesController,
                        labelText: 'Observações',
                        icon: Icons.notes,
                      ),
                      const SizedBox(height: 24),
                      /*  ElevatedButton(
                        onPressed: _saveForm,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Salvar Cliente'),
                      ),*/
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
