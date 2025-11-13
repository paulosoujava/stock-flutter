// Ficheiro: lib/presentation/pages/live_sales/form/live_form_page.dart

import 'package:flutter/material.dart';

class LiveFormPage extends StatefulWidget {
  const LiveFormPage({super.key});

  @override
  State<LiveFormPage> createState() => _LiveFormPageState();
}

class _LiveFormPageState extends State<LiveFormPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Live'),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                // Salvar e voltar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Live salva com sucesso!'),
                      backgroundColor: Colors.green),
                );
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text('SALVAR  LIVE',
                style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              // Adiciona um padding para um visual melhor
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ),
        ],
      ),
      // O corpo agora usa um `Center` para alinhar o conteúdo.
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          // O `Card` agora envolve todo o formulário.
          child: Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  // Ocupa o mínimo de espaço vertical.
                  children: [
                    // --- TÍTULO DA SEÇÃO ---
                    Text(
                      'Detalhes da Live',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),

                    // --- CAMPOS DO FORMULÁRIO ---
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Título da Live',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) =>
                          (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Data de Início',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today)),
                            readOnly: true,
                            onTap: () async => await showDatePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Hora de Início',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time)),
                            readOnly: true,
                            onTap: () async => await showTimePicker(
                                context: context, initialTime: TimeOfDay.now()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Data de Fim',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event_busy)),
                            readOnly: true,
                            onTap: () async => await showDatePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Hora de Fim',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.hourglass_bottom)),
                            readOnly: true,
                            onTap: () async => await showTimePicker(
                                context: context, initialTime: TimeOfDay.now()),
                          ),
                        ),
                      ],
                    ),

                    // --- DIVISOR PARA A SEÇÃO DE PRODUTOS ---
                    const Divider(height: 48),

                    // --- SEÇÃO DE PRODUTOS NA LIVE (CÓDIGO RESTAURADO) ---
                    Text(
                      'Produtos na Live',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),

                    // Campo de pesquisa de produtos
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Pesquisar e adicionar produto',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          onPressed: () {
                            /* TODO: Lógica de busca e adição de produto */
                          },
                          icon: const Icon(Icons.add_circle),
                          tooltip: 'Adicionar Produto',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista de produtos já adicionados à live
                    // Usamos um Container com borda para agrupar visualmente
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // ListView para os produtos adicionados
                      child: ListView(
                        shrinkWrap: true,
                        // Para o ListView funcionar dentro de um Column
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          // Exemplo de produto adicionado
                          ListTile(
                            leading: Icon(Icons.inventory_2_outlined),
                            title: Text('Camiseta Estampada Sol'),
                            subtitle: Text('Estoque disponível: 35'),
                            trailing: Tooltip(
                              message: 'Remover Produto',
                              child:
                                  Icon(Icons.delete_outline, color: Colors.red),
                            ),
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.inventory_2_outlined),
                            title: Text('Shorts Jeans Verão'),
                            subtitle: Text('Estoque disponível: 12'),
                            trailing: Tooltip(
                              message: 'Remover Produto',
                              child:
                                  Icon(Icons.delete_outline, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // AQUI ESTÁ A CORREÇÃO:
                    // Adiciona um espaço no final do formulário para o FAB.
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
