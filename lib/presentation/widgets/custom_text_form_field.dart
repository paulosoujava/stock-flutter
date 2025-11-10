import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Um widget de campo de texto reutilizável com um estilo padronizado.
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  /// Controla se o campo de texto pode ser editado. O padrão é `true`.
  final bool enabled;

  /// Uma lista de formatadores para aplicar ao campo (ex: máscaras).
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    // Adiciona os novos parâmetros ao construtor
    this.enabled = true,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        // Repassa as novas propriedades para o widget interno do Flutter
        enabled: enabled,
        inputFormatters: inputFormatters,

        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Bônus: Feedback visual para quando o campo está desabilitado
          filled: !enabled,
          fillColor: !enabled ? Colors.grey[200] : null,
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
