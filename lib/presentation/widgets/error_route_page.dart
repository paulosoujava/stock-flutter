import 'package:flutter/material.dart';

class ErrorRoutePage extends StatelessWidget {
  final String errorMessage;
  const ErrorRoutePage({super.key, this.errorMessage = 'Página não encontrada'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erro de Navegação'),
      ),
      body: Center(
        child: Text(errorMessage),
      ),
    );
  }
}
