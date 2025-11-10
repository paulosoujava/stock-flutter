// lib/presentation/pages/categories/form/category_form_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/category/category.dart';
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
        title: const  Text('Categoria'),
      ),
      body: StreamBuilder<CategoryFormState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is CategoryCreateLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Text(
                    isEditing ? 'Editar Categoria':  'Adicionar Nova Categoria',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(isEditing ? 'Você está no modo de edição da categoria.' : 'Crie categorias para organizar seus produtos de forma eficiente.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Categoria',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O nome da categoria é obrigatório.';
                      }
                      return null;
                    },
                  ),
                  const Spacer(), // Empurra o botão para baixo
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Categoria'),
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
