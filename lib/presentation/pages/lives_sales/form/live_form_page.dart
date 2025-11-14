// Ficheiro: lib/presentation/pages/live_sales/form/live_form_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock/core/di/injection.dart';import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/pages/lives_sales/form/live_form_intent.dart';
import 'package:stock/presentation/pages/lives_sales/form/live_form_state.dart';
import 'package:stock/presentation/pages/lives_sales/form/live_form_viewmodel.dart';

class LiveFormPage extends StatefulWidget {
  const LiveFormPage({super.key});

  @override
  State<LiveFormPage> createState() => _LiveFormPageState();
}

class _LiveFormPageState extends State<LiveFormPage> {
  // Chaves e Controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late final LiveFormViewModel _viewModel;
  DateTime? _startDateTime;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<LiveFormViewModel>();
    _viewModel.handleIntent(LoadInitialDataIntent());

    _viewModel.state.listen((state) {
      if (!mounted) return;
      if (state is LiveFormSaveSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Live agendada com sucesso!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } else if (state is LiveFormErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(state.errorMessage), backgroundColor: Colors.red),
        );
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Nova Live'),
      ),
      body: StreamBuilder<LiveFormState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is LiveFormLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LiveFormReadyState) {
            return _buildForm(context, state);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Não foi possível carregar os dados.'),
                ElevatedButton(
                  onPressed: () =>
                      _viewModel.handleIntent(LoadInitialDataIntent()),
                  child: const Text('Tentar Novamente'),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveLive,
        tooltip: 'Agendar Live',
        icon: const Icon(Icons.save),
        label: const Text('AGENDAR LIVE'),
      ),
    );
  }

  Widget _buildForm(BuildContext context, LiveFormReadyState state) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Detalhes da Live',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  _buildDetailsFields(),
                  const Divider(height: 48),
                  Text('Produtos da Live',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  _buildProductSearch(context, state),
                  const SizedBox(height: 16),
                  // AQUI ESTÁ A PRIMEIRA CORREÇÃO:
                  _buildProductList(state.tempProductsInLive),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveLive() {
    if (_formKey.currentState?.validate() ?? false) {

      final currentProductsInLive = (_viewModel.currentState as LiveFormReadyState).tempProductsInLive;

      if (currentProductsInLive.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Adicione pelo menos um produto à live.'),
              backgroundColor: Colors.orange),
        );
        return;
      }

      _viewModel.handleIntent(SaveLiveIntent(
        title: _titleController.text,
        description: _descriptionController.text,
        productsInLive: currentProductsInLive,
      ));
    }
  }

  Widget _buildDetailsFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
              labelText: 'Título da Live',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title)),
          validator: (value) =>
          (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
              labelText: 'Descrição',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description_outlined)),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProductSearch(BuildContext context, LiveFormReadyState state) {
    return Autocomplete<Product>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Product>.empty();
        }
        return state.allAvailableProducts.where((p) =>
            p.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                      onTap: () {
                        onSelected(option);
                      },
                      child: ListTile(title: Text(option.name)));
                },
              ),
            ),
          ),
        );
      },
      displayStringForOption: (Product option) => '',
      onSelected: (Product selection) {
        _viewModel.handleIntent(AddProductToLiveIntent(selection));
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Pesquisar produto para adicionar...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
        );
      },
    );
  }

  Widget _buildProductList(List<Product> productsInLive) {
    if (productsInLive.isEmpty) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Nenhum produto adicionado à live ainda.')));
    }
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: productsInLive.length,
        itemBuilder: (context, index) {
          final product = productsInLive[index];
          return ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(product.name),
            subtitle: Text('Estoque disponível: ${product.stockQuantity}'),
            trailing: Tooltip(
              message: 'Remover Produto',
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _viewModel
                    .handleIntent(RemoveProductFromLiveIntent(product)),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }

}
