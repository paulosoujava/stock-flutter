// Ficheiro: lib/core/utils/url_launcher_utils.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherUtils {
  static Future<void> launchEmail(BuildContext context, String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Ajuda sobre o App de Estoque'},
    );
    _launch(context, emailLaunchUri);
  }

  static Future<void> launchPhone(BuildContext context, String phoneNumber) async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
    _launch(context, phoneLaunchUri);
  }

  static Future<void> launchWhatsApp(BuildContext context, String phoneNumber) async {
    final String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri whatsappLaunchUri = Uri.parse('https://wa.me/55$cleanedNumber');
    _launch(context, whatsappLaunchUri, mode: LaunchMode.externalApplication);
  }

  static Future<void> _launch(BuildContext context, Uri url, {LaunchMode mode = LaunchMode.platformDefault}) async {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: mode);
      } else {
        if (context.mounted) {
          _showError(context, 'Não foi possível abrir o link.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Ocorreu um erro: $e');
      }
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  static Future<void> launchMap(BuildContext context, String address) async {
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

  static void showErrorSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }



}
