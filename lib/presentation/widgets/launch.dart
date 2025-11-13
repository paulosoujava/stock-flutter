import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchMap( String address,BuildContext context) async {
  // Codifica o endereço para que espaços e caracteres especiais funcionem na URL
  final Uri encodedAddress = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}'
  );

  try {
    if (await canLaunchUrl(encodedAddress)) {
      await launchUrl(encodedAddress);
    } else {
      // Se não conseguir abrir a URL do mapa, mostra um erro.
      showErrorSnackbar(context, 'Não foi possível abrir o mapa.');
    }
  } catch (e) {
    showErrorSnackbar(context, 'Erro ao tentar abrir o mapa: $e');
  }
}

void showErrorSnackbar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

/// Abre o WhatsApp de forma otimizada para desktop e mobile.
Future<void> launchWhatsApp(String phoneNumber, BuildContext context) async {
  final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  final whatsappUrlApi = Uri.parse("https://wa.me/55$cleanPhone");

  try {
    if (await canLaunchUrl(whatsappUrlApi)) {
      // LaunchMode.externalApplication é a melhor opção multiplataforma.
      // No mobile, abre o app. No desktop, abre o navegador que então
      // tentará abrir o app desktop, que é o comportamento esperado.
      await launchUrl(whatsappUrlApi, mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir o WhatsApp.';
    }
  } catch (e) {
    // Mostra um feedback claro para o usuário caso algo dê errado.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro ao abrir o WhatsApp: Verifique se está instalado.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
