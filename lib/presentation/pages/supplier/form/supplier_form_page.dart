import 'package:flutter/material.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/supplier/supplier.dart';
import 'package:stock/presentation/pages/supplier/form/supplier_form_intent.dart';
import 'package:stock/presentation/pages/supplier/form/supplier_form_state.dart';
import 'package:stock/presentation/pages/supplier/form/supplier_form_viewmodel.dart';
import 'package:go_router/go_router.dart';

class SupplierFormPage extends StatefulWidget {
  final Supplier? supplierToEdit;
  const SupplierFormPage({super.key, this.supplierToEdit});

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  late final SupplierFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _observationController;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SupplierFormViewModel>();
    _isEditing = widget.supplierToEdit != null;

    _nameController = TextEditingController(text: widget.supplierToEdit?.name);
    _phoneController = TextEditingController(text: widget.supplierToEdit?.phone);
    _emailController = TextEditingController(text: widget.supplierToEdit?.email);
    _observationController =
        TextEditingController(text: widget.supplierToEdit?.observation);

    _viewModel.state.listen((state) {
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
        phone: _phoneController.text,
        email: _emailController.text,
        observation: _observationController.text,
      );
      _viewModel.handleIntent(SaveSupplierIntent(supplier));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Fornecedor' : 'Novo Fornecedor'),
        actions: const [],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveForm,
        label: const Text('Salvar'),
        icon: const Icon(Icons.save),
      ),
      body: StreamBuilder<SupplierFormState>(
          stream: _viewModel.state,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state is SupplierFormLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) =>
                            value!.isEmpty ? 'Campo obrigatório' : null,
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
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _observationController,
                            decoration: const InputDecoration(
                              labelText: 'Observação',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.notes),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
