// lib/presentation/pages/categories/form/category_form_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/category/category.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'category_form_intent.dart';
import 'category_form_state.dart';
import 'category_form_viewmodel.dart';

class CategoryCreatePage extends StatefulWidget {
  final Category? categoryToEdit;

  const CategoryCreatePage({super.key, this.categoryToEdit});

  @override
  State<CategoryCreatePage> createState() => _CategoryCreatePageState();
}

class _CategoryCreatePageState extends State<CategoryCreatePage> {
  late final CategoryCreateViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool get isEditing => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CategoryCreateViewModel>();

    if (isEditing) {
      _nameController.text = widget.categoryToEdit!.name;
    }

    _viewModel.state.listen((state) {
      if (!mounted) return;

      if (state is CategoryCreateSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categoria salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Retorna 'true' para a tela anterior saber que precisa atualizar
        context.pop(true);
      } else if (state is CategoryCreateErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Categoria' : 'Nova Categoria'),
      ),
      // AQUI ESTÁ A CORREÇÃO, SEGUINDO O PADRÃO
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveForm,
        label: Text(isEditing ? 'Atualizar' : 'Salvar'),
        icon: const Icon(Icons.save),
      ),
      body: StreamBuilder<CategoryFormState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is CategoryCreateLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            "Digite o nome da categoria para associar com os produtos:",
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.start,
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
                        // O ElevatedButton foi removido daqui
                      ],
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
