import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/supplier/supplier.dart';
import 'package:stock/presentation/pages/supplier/form/supplier_form_intent.dart';
import 'package:stock/presentation/pages/supplier/form/supplier_form_state.dart';
import 'package:stock/presentation/pages/supplier/form/supplier_form_viewmodel.dart';

class SupplierFormPage extends StatefulWidget {
  final Supplier? supplierToEdit;
  const SupplierFormPage({super.key, this.supplierToEdit});

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  // --- LÓGICA ORIGINAL 100% PRESERVADA ---
  late final SupplierFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _observationController;
  late bool _isEditing;

  final _phoneMaskFormatter =
  MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SupplierFormViewModel>();
    _isEditing = widget.supplierToEdit != null;

    _nameController = TextEditingController(text: widget.supplierToEdit?.name);
    _phoneController = TextEditingController(); // Inicializado vazio
    _emailController = TextEditingController(text: widget.supplierToEdit?.email);
    _observationController =
        TextEditingController(text: widget.supplierToEdit?.observation);

    // Aplica a máscara após o controller ser criado
    _phoneController.text = _phoneMaskFormatter.maskText(widget.supplierToEdit?.phone ?? '');

    _viewModel.state.listen((state) {
      if (!mounted) return;
      if (state is SupplierFormSuccess) {
        context.pop(true);
      }
      if (state is SupplierFormError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.red));
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final supplier = Supplier(
        id: widget.supplierToEdit?.id ?? '',
        name: _nameController.text,
        phone: _phoneMaskFormatter.getUnmaskedText(), // Salva o número limpo
        email: _emailController.text,
        observation: _observationController.text,
      );
      _viewModel.handleIntent(SaveSupplierIntent(supplier));
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
            child: StreamBuilder<SupplierFormState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                final state = snapshot.data;
                if (state is SupplierFormLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: _buildFormFields(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
            offset: const Offset(0, 4),
          ),
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
            _isEditing ? 'Editar Fornecedor' : 'Novo Fornecedor',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            icon: const Icon(Icons.save, size: 20),
            label: const Text("Salvar"),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do Fornecedor',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business_center),
            ),
            validator: (value) =>
            value!.isEmpty ? 'O nome é obrigatório' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Telefone',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMaskFormatter],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'O telefone é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'E-mail (opcional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _observationController,
            decoration: const InputDecoration(
              labelText: 'Observação (opcional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }
}