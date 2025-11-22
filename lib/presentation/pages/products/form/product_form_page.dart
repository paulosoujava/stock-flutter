import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/widgets/custom_text_form_field.dart';

import '../../../../core/di/app_module.dart';
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
  late final ProductFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  final _codeOfProductController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _unitOfMeasureController = TextEditingController(text: 'un');

  final _salePriceController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  final _costPriceController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );

  final _stockQuantityController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();

  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProductFormViewModel>();

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
    _codeOfProductController.text = product.name;
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
        lowStockThreshold: int.tryParse(_lowStockThresholdController.text) ?? 0,
        categoryId: widget.category.id,
      );

      if (isEditing) {
        _viewModel.handleIntent(UpdateProductIntent(productData));
      } else {
        _viewModel.handleIntent(SaveProductIntent(productData));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditing ? 'Editar Produto' : 'Novo Produto';

    return Scaffold(
      appBar: AppBar(
        title: Text(   '${title} na categoria: ${widget.category.name}'),
        ),

      body: StreamBuilder<ProductFormState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          if (snapshot.data is ProductFormLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // O formulário agora é centralizado e com largura máxima.
          return Center(
            child: ConstrainedBox(
              // Define uma largura máxima para o formulário, ideal para desktop.
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextFormField(
                            controller: _codeOfProductController,
                            labelText: 'Código do Produto',
                            icon: Icons.qr_code_2_outlined, // Ícone melhorado
                            validator: (value) => (value?.isEmpty ?? true)
                                ? 'O código é obrigatório.'
                                : null,
                          ),
                          CustomTextFormField(
                            controller: _nameController,
                            labelText: 'Título do Produto',
                            icon: Icons.label_important_outline,
                            validator: (value) => (value?.isEmpty ?? true)
                                ? 'O título é obrigatório.'
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Descrição',
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              maxLines: 4,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  controller: _costPriceController,
                                  labelText: 'Valor de Compra',
                                  icon: Icons.arrow_downward,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextFormField(
                                  controller: _salePriceController,
                                  labelText: 'Valor de Venda',
                                  icon: Icons.arrow_upward,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
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
                                  labelText: 'Alerta de Estoque',
                                  icon: Icons.warning_amber_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          // Espaço extra para o FloatingActionButton não cobrir o último campo.
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FloatingActionButton.extended(
                                onPressed: _saveForm,
                                label: Text(isEditing ? 'Atualizar' : 'Salvar'),
                                icon: const Icon(Icons.save),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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
