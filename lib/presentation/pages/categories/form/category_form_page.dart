// lib/presentation/pages/categories/form/category_form_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'category_form_intent.dart';
import 'category_form_state.dart';
import 'category_form_viewmodel.dart';
import '../../../widgets/custom_text_form_field.dart';


class CategoryFormPage extends StatelessWidget {
  final Category? categoryToEdit;

  const CategoryFormPage({super.key, this.categoryToEdit});


  static Future<bool?> showAsModal(BuildContext context, {Category? category}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: false, // Permite o modal crescer e o teclado não o cobrir.
      backgroundColor: Colors.transparent, // Deixa o Card arredondado aparecer.
      builder: (ctx) => _CategoryFormContent(
        categoryToEdit: category,
        isModal: true, // Informa ao widget que ele está em um modal.
      ),
    );
  }

  // A construção da página de tela cheia continua funcionando normalmente.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryToEdit != null ? 'Editar Categoria' : 'Nova Categoria'),
      ),
      body: _CategoryFormContent(
        categoryToEdit: categoryToEdit,
        isModal: false, // Informa que NÃO está em um modal.
      ),
    );
  }
}

// 3. O CONTEÚDO DO FORMULÁRIO é extraído para este widget.
class _CategoryFormContent extends StatefulWidget {
  final Category? categoryToEdit;
  final bool isModal;

  const _CategoryFormContent({this.categoryToEdit, this.isModal = false});

  @override
  State<_CategoryFormContent> createState() => _CategoryFormContentState();
}

class _CategoryFormContentState extends State<_CategoryFormContent> {
  // 4. TODA A LÓGICA ANTERIOR (controllers, keys, viewmodel) vem para cá.
  late final CategoryFormViewModel _viewModel; // ViewModel renomeado para ser genérico.
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool get isEditing => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CategoryFormViewModel>(); // ViewModel renomeado

    if (isEditing) {
      _nameController.text = widget.categoryToEdit!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final categoryData = Category(
        id: isEditing ? widget.categoryToEdit!.id : '',
        name: _nameController.text.trim(),
      );

      if (isEditing) {
        _viewModel.handleIntent(UpdateCategoryIntent(categoryData));
      } else {
        _viewModel.handleIntent(SaveCategoryIntent(categoryData));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 5. A UI do formulário agora é controlada por este widget.
    return Scaffold(
      // Usamos um Scaffold aqui para que o FloatingActionButton e o ScaffoldMessenger funcionem corretamente.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveForm,
        label: Text(isEditing ? 'Atualizar' : 'Salvar'),
        icon: const Icon(Icons.save),
      ),
      body: StreamBuilder<CategoryFormState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          // Lógica para lidar com os estados (sucesso, erro, loading)
          if (state is CategoryFormSuccessState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Retorna 'true' para fechar o modal e indicar sucesso.
              Navigator.of(context).pop(true);
            });
          } else if (state is CategoryFormErrorState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            });
          }

          if (state is CategoryFormLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          // O layout do formulário em si.
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Importante para o modal
                children: [
                  // Adiciona um título visível apenas no modo modal
                  if (widget.isModal)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                      child: Text(
                        isEditing ? 'Editar Categoria' : 'Nova Categoria',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      "Digite o nome da categoria para associar com os produtos:",
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  CustomTextFormField(
                    controller: _nameController,
                    labelText: 'Nome da Categoria',
                    icon: Icons.label_important_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O nome da categoria é obrigatório.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 80), // Espaço para o FAB não cobrir o campo.
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
