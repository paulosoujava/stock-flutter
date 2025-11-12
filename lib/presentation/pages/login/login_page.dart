// lib/presentation/pages/login/login_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/presentation/pages/login/login_intent.dart';
import 'package:stock/presentation/pages/login/login_state.dart';
import 'package:stock/presentation/pages/login/login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginViewModel _viewModel;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<LoginViewModel>();

    _viewModel.state.listen((state) {
      if (!mounted) return;

      if (state is LoginSuccess) {
        context.go(AppRoutes.home);
      }
      if (state is LoginError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
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
    _viewModel.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_formKey.currentState?.validate() ?? false) {
      _viewModel.handleIntent(
        SignInWithEmailAndPasswordIntent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  // 1. MÉTODO PARA MOSTRAR O POP-UP
  void _showRequestAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Solicitação de Acesso'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Para solicitar seu acesso, entre em contato:'),
                SizedBox(height: 16),
                Text('E-mail: paulosoujava@gmail.com'),
                SizedBox(height: 8),
                Text('Telefone: (48) 99629-7813'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('FECHAR'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<LoginState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final isLoading = snapshot.data is LoginLoading;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.storefront,
                            size: 80,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bem-vindo',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => (value?.isEmpty ?? true)
                                ? 'E-mail é obrigatório'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                            validator: (value) => (value?.isEmpty ?? true)
                                ? 'Senha é obrigatória'
                                : null,
                          ),
                          const SizedBox(height: 44),
                          if (isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: _signIn,
                              style: ElevatedButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 26),
                              ),
                              child: const Text('ENTRAR'),
                            ),
                          // 2. TEXTBUTTON ADICIONADO AQUI
                          const SizedBox(height: 36),
                          TextButton(
                            onPressed: () => _showRequestAccountDialog(context),
                            child: const Text('Solicite uma conta'),
                          ),
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
