import 'package:flutter/material.dart';
import 'package:stock/presentation/widgets/contact_info_row.dart';
import 'package:stock/presentation/widgets/url_launcher_utils.dart';

class HelpDialog {
  static void show(BuildContext context) {
    const String email = 'paulosoujava@gmail.com';
    const String phone = '(48) 99629-7813';
    // O mesmo número, mas sem formatação, para a função do WhatsApp
    const String whatsappNumber = '48996297813';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Ajuda'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  'Precisa de ajuda? Entre em contato com o desenvolvedor, clicando em uma das opções abaixo:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ContactInfoRow(
                  icon: Icons.email_outlined,
                  text: email,
                  onTap: () => UrlLauncherUtils.launchEmail(dialogContext, email),
                ),
                ContactInfoRow(
                  icon: Icons.phone_outlined,
                  text: phone,
                  onTap: () => UrlLauncherUtils.launchPhone(dialogContext, phone),
                ),
                ContactInfoRow(
                  icon: Icons.chat_bubble_outline,
                  text: 'WhatsApp',
                  onTap: () => UrlLauncherUtils.launchWhatsApp(dialogContext, whatsappNumber),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
