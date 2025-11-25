import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/widgets/custom_text_form_field.dart';

import 'product_form_intent.dart';
import 'product_form_state.dart';
import 'product_form_viewmodel.dart';

class ProductFormPage extends StatefulWidget {
  final Category category;
  final Product? productToEdit;

  const ProductFormPage({
    super.key,
    required this.category,
    this.productToEdit,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  // --- LÓGICA ORIGINAL 100% PRESERVADA ---
  late final ProductFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  final _codeOfProductController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _unitOfMeasureController = TextEditingController(text: 'un');

  final _salePriceController = MoneyMaskedTextController(
      leftSymbol: 'R\$ ', decimalSeparator: ',', thousandSeparator: '.');
  final _costPriceController = MoneyMaskedTextController(
      leftSymbol: 'R\$ ', decimalSeparator: ',', thousandSeparator: '.');

  final _stockQuantityController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  String initialCode = '';
  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProductFormViewModel>();

// Escuta o stream uma única vez para pegar o código sugerido
    final subscription = _viewModel.state.listen((state) {
      if (state is ProductFormNextCodeSuggested && !isEditing) {
        setState(() {
          initialCode = state.suggestedCode;
          // Atualiza o controller com o código sugerido
          _codeOfProductController.text = initialCode;
          _codeOfProductController.selection = TextSelection.fromPosition(
            TextPosition(offset: initialCode.length),
          );
        });
        //subscription.cancel(); // cancela após usar (evita múltiplas chamadas)
      }
    });

    // Se estiver editando, preenche com o código do produto existente
    if (isEditing && widget.productToEdit!.codeOfProduct != null) {
      initialCode = widget.productToEdit!.codeOfProduct!;
      _codeOfProductController.text = initialCode;
    }

    if (isEditing) {
      _populateFieldsForEditing();
    }

    _viewModel.state.listen((state) {
      if (!mounted) return;
      if (state is ProductFormSuccess) {
        context.pop(true);
      } else if (state is ProductFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
      }
    });
  }

  void _populateFieldsForEditing() {
    final product = widget.productToEdit!;
    _codeOfProductController.text = product.codeOfProduct ?? '';
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _salePriceController.updateValue(product.salePrice);
    _costPriceController.updateValue(product.costPrice);
    _stockQuantityController.text = product.stockQuantity.toString();
    _lowStockThresholdController.text = product.lowStockThreshold.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _salePriceController.dispose();
    _costPriceController.dispose();
    _stockQuantityController.dispose();
    _lowStockThresholdController.dispose();
    _barcodeController.dispose();
    _unitOfMeasureController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final productData = Product(
        id: isEditing ? widget.productToEdit!.id : '',
        codeOfProduct: _codeOfProductController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        salePrice: _salePriceController.numberValue,
        costPrice: _costPriceController.numberValue,
        stockQuantity: int.tryParse(_stockQuantityController.text) ?? 0,
        lowStockThreshold:
        int.tryParse(_lowStockThresholdController.text) ?? 0,
        categoryId: widget.category.id,
      );

      if (isEditing) {
        _viewModel.handleIntent(UpdateProductIntent(productData));
      } else {
        _viewModel.handleIntent(SaveProductIntent(productData));
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
            child: StreamBuilder<ProductFormState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                if (snapshot.data is ProductFormLoading) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Editar Produto' : 'Novo Produto',
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800]),
                ),
                Text(
                  'na categoria: ${widget.category.name}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
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
          // --- Seção de Informações Básicas ---
          _buildSectionTitle('Informações Básicas'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: CustomTextFormField(
                  enabled: !isEditing,
                  controller: _codeOfProductController,
                  labelText: 'Código do Produto',
                  icon: Icons.qr_code_2_outlined,
                  validator: (value) =>
                  (value?.isEmpty ?? true) ? 'O código é obrigatório.' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: CustomTextFormField(
                  controller: _nameController,
                  labelText: 'Nome do Produto',
                  icon: Icons.label_important_outline,
                  validator: (value) => (value?.isEmpty ?? true)
                      ? 'O nome é obrigatório.'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),

          const Divider(height: 48),

          // --- Seção de Valores ---
          _buildSectionTitle('Valores'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: _costPriceController,
                  labelText: 'Preço de Custo',
                  icon: Icons.arrow_downward,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextFormField(
                  controller: _salePriceController,
                  labelText: 'Preço de Venda',
                  icon: Icons.arrow_upward,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (_salePriceController.numberValue <= 0) {
                      return 'Obrigatório e > 0.';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const Divider(height: 48),

          // --- Seção de Estoque ---
          _buildSectionTitle('Controle de Estoque'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: _stockQuantityController,
                  labelText: 'Qtd. em Estoque',
                  icon: Icons.inventory_2_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextFormField(
                  controller: _lowStockThresholdController,
                  labelText: 'Alerta de Estoque Baixo',
                  icon: Icons.warning_amber_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper para os títulos de seção
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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